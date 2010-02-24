
require 'ostruct'
require 'find'

require 'awestruct/config'
require 'awestruct/site'
require 'awestruct/haml_file'
require 'awestruct/sass_file'
require 'awestruct/verbatim_file'

require 'rss'

require 'awestruct/haml_helpers'

module Awestruct

  IGNORE_NAMES = [
    'hekyll',
  ]

  class Engine

    attr_reader :config
    attr_reader :dir
    attr_reader :site

    def initialize(dir, config=::Awestruct::Config.new)
      @dir    = dir
      @config = config
      @site   = Site.new( @dir )
    end

    def generate()
      load_layouts
      load_yamls
      load_pages
      load_extensions
      set_urls
      generate_files
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
      end
    end

    def generate_files()
      site.pages.each do |page|
        generated_path = File.join( dir, config.output_dir, page.output_path )
        $stderr.puts "rendering #{page.source_path}"
        rendered = render_page(page, true)
        #$stderr.puts "writing #{generated_path}"
        FileUtils.mkdir_p( File.dirname( generated_path ) )
        File.open( generated_path, 'w' ) do |file|
          file << rendered
        end
      end
    end

    def render_page(page, with_layouts=true)
      context = OpenStruct.new( :site=>site, :content=>'' )
      context.page = page
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
        site.layouts[ name ] =  HamlFile.new( site, layout_path, relative_path )
      end
    end

    def load_yamls
      Dir[ File.join( dir, config.config_dir, '*.yml' ) ].each do |yaml_path|
        data = YAML.load( File.read( yaml_path ) )
        name = File.basename( yaml_path, '.yml' )
        site.send( "#{name}=", massage_yaml( data ) )
      end
    end

    def load_pages()
      dir_pathname = Pathname.new( dir )
      Find.find( dir ) do |path|
        basename = File.basename( path )
        if ( config.ignore.include?( basename ) || ( basename =~ /^[_.]/ ) )
          Find.prune
          next
        end
        unless ( site.has_page?( path ) )
          file_pathname = Pathname.new( path )
          relative_path = file_pathname.relative_path_from( dir_pathname ).to_s
          if ( path =~ /\.haml$/ )
            site.pages << HamlFile.new( site, path, relative_path )
          elsif ( path =~ /\.sass$/ )
            site.pages << SassFile.new( site, path, relative_path )
          elsif ( File.file?( path ) )
            site.pages << VerbatimFile.new( site, path, relative_path )
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
        load( path )
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
