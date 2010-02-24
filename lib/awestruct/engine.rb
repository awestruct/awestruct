
require 'ostruct'
require 'find'

require 'awestruct/config'
require 'awestruct/site'
require 'awestruct/haml_page'
require 'awestruct/sass_page'
require 'awestruct/verbatim_file'

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
      puts config.inspect
      puts "@dir is #{dir}"
      load_layouts
      load_yamls
      load_pages
      generate_files
    end

    private

    def output_path(path)
      File.join( dir, config.output_dir, path[ @dir.size..-1] )
    end

    def generate_files()
      site.pages.each do |page|
        rendered = render_page(page, true)
        generated_path = nil
        if ( page.output_path )
          generated_path = File.join( dir, config.output_dir, page.output_page )
        else
          generated_path = File.join( File.dirname( output_path( page.source_path ) ), page.output_filename )
        end
        $stderr.puts "generating #{generated_path}"
        FileUtils.mkdir_p( File.dirname( generated_path ) )
        File.open( generated_path, 'w' ) do |file|
          file << rendered
        end
      end
    end

    def render_page(page, with_layouts=true)
      context = OpenStruct.new( :site=>site, :content=>'' )
      $stderr.puts "rendering #{page.source_path}"
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
      Dir[ File.join( dir, config.layouts_dir, '*.haml' ) ].each do |layout_path|
        name = File.basename( layout_path, '.haml' )
        site.layouts[ name ] =  HamlPage.new( site, layout_path )
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
      Find.find( dir ) do |path|
        basename = File.basename( path )
        if ( config.ignore.include?( basename ) || ( basename =~ /^[_.]/ ) )
          Find.prune
          next
        end
        unless ( site.has_page?( path ) )
          if ( path =~ /\.haml$/ )
            site.pages << HamlPage.new( site, path )
          elsif ( path =~ /\.sass$/ )
            site.pages << SassPage.new( site, path )
          elsif ( File.file?( path ) )
            site.pages << VerbatimFile.new( site, path )
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

  end

end
