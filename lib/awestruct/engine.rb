
require 'ostruct'
require 'find'
require 'compass'
require 'time'

require 'awestruct/config'
require 'awestruct/site'
require 'awestruct/haml_file'
require 'awestruct/maruku_file'
require 'awestruct/sass_file'
require 'awestruct/verbatim_file'

require 'awestruct/haml_helpers'

require 'awestruct/extensions/pipeline'
require 'awestruct/extensions/posts'
require 'awestruct/extensions/indexifier'
require 'awestruct/extensions/paginator'

require 'awestruct/util/inflector'
require 'awestruct/util/default_inflections'

module Awestruct

  class Engine

    attr_reader :config
    attr_reader :dir
    attr_reader :site

    def initialize(dir, config=::Awestruct::Config.new)
      @dir    = dir
      @config = config
      @site   = Site.new( @dir )
      @site.engine = self
      @site.tmp_dir = File.join( dir, '_tmp' )
      FileUtils.mkdir_p( @site.tmp_dir )
      FileUtils.mkdir_p( @site.output_dir )
      @max_yaml_mtime = nil
    end

    def generate(base_url=nil, force=false)
      @base_url = base_url
      load_layouts
      load_yamls
      load_pages
      load_extensions
      set_urls
      generate_files(force)
    end

    def find_and_load_site_page(simple_path)
      path_glob = File.join( dir, simple_path + '.*' )
      candidates = Dir[ path_glob ]
      return nil if candidates.empty?
      throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
      load_page( candidates[0] )
    end

    def load_site_page(relative_path)
      load_page( File.join( dir, relative_path ) )
    end

    def load_page(path, relative_path=nil)
      page = nil
      if ( relative_path.nil? )
        dir_pathname = Pathname.new( dir )
        path_name = Pathname.new( path )
        relative_path = path_name.relative_path_from( dir_pathname ).to_s
      end
      if ( path =~ /\.haml$/ )
        page = HamlFile.new( site, path, File.join( '', relative_path ) )
      elsif ( path =~ /\.md$/ )
        page = MarukuFile.new( site, path, File.join( '', relative_path ) )
      elsif ( path =~ /\.sass$/ )
        page = SassFile.new( site, path, File.join( '', relative_path ) )
      elsif ( File.file?( path ) )
        page = VerbatimFile.new( site, path, File.join( '', relative_path ) )
      end
      page
    end


    private

    def set_urls
      site.pages.each do |page|
        page_path = page.output_path
        if ( page_path =~ /^\// )
          page.url = page_path
        else
          page.url = "/#{page_path}"
        end
        if ( page.url =~ /^(.*\/)index.html$/ )
          page.url = $1
        end
      end
    end

    def generate_files(force)
      site.pages.each do |page|
        generate_page( page, force )
      end
    end

    def generate_page(page, force)
      return unless requires_generation?(page, force)

      generated_path = File.join( dir, config.output_dir, page.output_path )
      $stderr.puts "rendering #{page.source_path} -> #{page.output_path}"
      rendered = render_page(page, true)
      FileUtils.mkdir_p( File.dirname( generated_path ) )
      File.open( generated_path, 'w' ) do |file|
        file << rendered
      end
    end

    def requires_generation?(page,force)
      return true if force
      generated_path = File.join( @dir, config.output_dir, page.output_path )
      return true unless File.exist?( generated_path )
      now = Time.now
      generated_mtime = File.mtime( generated_path )
      return true if ( ( @max_yaml_mtime || Time.at(0) ) > generated_mtime )
      source_mtime = File.mtime( page.source_path )
      return true if ( source_mtime > generated_mtime ) && ( source_mtime + 1 < now )
      ext = page.output_extension
      layout_name = page.layout
      while ( ! layout_name.nil? )
        layout = site.layouts[ layout_name + ext ]
        if ( layout )
          layout_mtime = File.mtime( layout.source_path )
          return true if layout_mtime > generated_mtime
        end
        layout_name = layout.layout
      end
      false
    end

    def self.create_context(site, page, content='')
      context = OpenStruct.new( :site=>site, :content=>content )
      context.page = page
      class << context
        def interpolate_string(str)
          result = instance_eval("%@#{(str||'').gsub('@', '\@')}@")
          result
        end
      end
      context
    end

    def render_page(page, with_layouts=true)
      context = Engine.create_context( site, page )
      rendered = page.render( context )
      if ( with_layouts )
        cur = page
        while ( ! cur.nil? && ! cur.layout.nil? )
          layout_name = cur.layout.to_s + page.output_extension
          cur = site.layouts[ layout_name ]
          context.content = rendered.to_s
          rendered = cur.render( context )
        end
      end
      rendered
    end

    def load_layouts
      dir_pathname = Pathname.new( dir )
      Dir[ File.join( dir, config.layouts_dir, '*.haml' ) ].each do |layout_path|
        layout_pathname = Pathname.new( layout_path )
        relative_path = layout_pathname.relative_path_from( dir_pathname ).to_s
        name = File.basename( layout_path, '.haml' )
        #site.layouts[ name ] =  HamlFile.new( site, layout_path, relative_path )
        site.layouts[ name ] =  load_page( layout_path, relative_path )
      end
    end

    def load_yamls
      @max_yaml_mtime = nil
      Dir[ File.join( dir, config.config_dir, '*.yml' ) ].each do |yaml_path|
        mtime = File.mtime( yaml_path )
        if ( mtime > ( @max_yaml_mtime || Time.at(0) ) )
          @max_yaml_mtime = mtime
        end
        data = YAML.load( File.read( yaml_path ) )
        name = File.basename( yaml_path, '.yml' )
        if ( name == 'site' )
          data.each do |k,v|
            site.send( "#{k}=", v )
          end
          ( site.base_url = @base_url ) if ( @base_url )
        else
          site.send( "#{name}=", massage_yaml( data ) )
        end
      end
    end

    def load_pages()
      dir_pathname = Pathname.new( dir )
      site.pages.clear
      Find.find( dir ) do |path|
        basename = File.basename( path )
        if ( basename == '.htaccess' )
          #special case
        elsif ( config.ignore.include?( basename ) || ( basename =~ /^[_.]/ ) )
          Find.prune
          next
        end
        unless ( site.has_page?( path ) )
          file_pathname = Pathname.new( path )
          relative_path = file_pathname.relative_path_from( dir_pathname ).to_s
          page = load_page( path, relative_path )
          if ( page )
            site.pages << page
          end
        end
      end
    end

    def massage_yaml(obj)
      result = obj
      case ( obj )
        when Hash
          result = {}
          obj.each do |k,v|
            result[k] = massage_yaml(v)
          end
          result = OpenStruct.new( result )
        when Array
          result = []
          obj.each do |v|
            result << massage_yaml(v)
          end
      end
      result
    end

    def load_extensions
      ext_dir = File.join( dir, config.extension_dir ) 
      pipeline_file = File.join( ext_dir, 'pipeline.rb' )
      if ( $LOAD_PATH.index( ext_dir ).nil? )
        $LOAD_PATH << ext_dir
      end
      pipeline = eval File.read( pipeline_file )
      pipeline.execute( site )
    end

    def old_load_extensions
      ext_dir_pathname = Pathname.new( File.join( dir, config.extension_dir ) )
      Dir[ File.join( dir, config.extension_dir, '*.rb' ) ].each do |path|
        ext_pathname = Pathname.new( path )
        relative_path = ext_pathname.relative_path_from( ext_dir_pathname ).to_s
        dir_name = File.dirname( relative_path )
        if ( dir_name == '.' )
          simple_path = File.basename( relative_path, '.rb' ) 
        else
          simple_path = File.join( dir_name, File.basename( relative_path, '.rb' ) )
        end
        ext_classname = camelize(simple_path)
        require File.join( dir, config.extension_dir, simple_path )
        ext_class = eval( ext_classname )
        ext = ext_class.new
        ext.execute( site )
      end
    end

    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end

  end

end
