require 'find'
require 'haml'
require 'sass'

module Hekyll

  IGNORE_NAMES = [
    'hekyll',
  ]

  class Engine

    def initialize(dir)
      @dir = dir
      @site = Site.new( @dir )
    end

    def generate()
      @site.generate
    end
  end

  class Site
    attr_reader :layouts
    def initialize(dir)
      @pages = {}
      @dir = dir
      @output_dir = File.join( dir, '_site' )
      @yaml_data = {}
      @layouts = {}
      load_yaml
      load_layouts
    end

    def scan()
      Find.find( @dir ) do |path|
        basename = File.basename( path )
        if ( IGNORE_NAMES.include?( basename ) || ( basename =~ /^[_.]/ ) )
          Find.prune
          next
        end
        if ( @pages[path].nil? )
          if ( path =~ /\.haml$/ )
            @pages[path] = HamlPage.new( path, output_path( path, '.haml' ) )
          elsif ( path =~ /\.sass$/ )
            @pages[path] = SassPage.new( path, output_path( path, '.sass' ) + '.css' )
          elsif ( File.file?( path ) )
            @pages[path] = CopyFile.new( path, output_path( path ) )
          end
        end
      end
    end

    def output_path(path, ext=nil)
      path = File.join( @output_dir, path[ @dir.size..-1] )
      unless ( ext.nil? )
        path = File.join( File.dirname( path ), File.basename( path, ext ) )
      end
      path 
    end

    def load_yaml
      if ( File.exist?( File.join( @dir, '_config.yml' ) ) )
        @yaml_data = YAML.load( File.read( File.join( @dir, '_config.yml' ) ) )
      end
    end

    def load_layouts
      Dir[ File.join( @dir, '_layouts', '*.haml' ) ].each do |layout_path|
        name = File.basename( layout_path, '.haml' )
        name = File.basename( name, '.html' )
        @layouts[ name ] = HamlPage.new( layout_path, nil )
      end
    end

    def method_missing(sym, *args)
      return super unless @yaml_data[sym.to_s]
      @yaml_data[sym.to_s]
    end

    def generate()
      scan()
      @pages.values.each do |page|
        if ( page.modified?( self ) )
          $stderr.puts "generating #{page.output_path}"
          rendered = page.render( self )
          cur = page
          while ( ! cur.nil? && ! cur.layout.nil? )
            cur = @layouts[ page.layout.to_s ]
            rendered = cur.render( self, page, rendered )
          end
          File.open( page.output_path, 'w' ) do |file|
            file << rendered
          end
        end
      end
    end
  end

  class Renderable

    attr_reader :path
    attr_reader :output_path

    def initialize(path, output_path)
      @path = path
      @output_path = output_path
    end

    def prepare()
      return if output_path.nil?
      FileUtils.mkdir_p( File.dirname( output_path ) )
    end

    def render(site, page=nil, content='')
      prepare
      do_render(site, page, content)
    end

    def do_render(site, page=nil, content='')
      puts "render(site) not implemented"
    end

    def modified?(site, compare_path=nil)
      compare_path ||= output_path
      return true unless File.exists?( compare_path )
      cur = self
      while ( ! cur.nil? )
        return true if ( File.mtime( cur.path ) > File.mtime( compare_path ) )
        cur = site.layouts[ cur.layout ]
      end
      false
    end

  end

  class CopyFile < Renderable
    def initialize(path, output_path)
      super( path, output_path )
    end

    def do_render(site, page=nil, content='')
      File.read( path )
    end

    def layout
      nil
    end
  end

  class SassPage < Renderable
    def initialize(path, output_path)
      super( path, output_path )
    end

    def do_render(site, page=nil, content=nil)
      sass_engine = Sass::Engine.new( File.read( path ) )
      sass_engine.render
    end

    def layout
      nil
    end
  end

  class HamlPage < Renderable
    def initialize(path, output_path)
      super( path, output_path )
      read()
    end

    def read()
      @full_content = File.read( path )
      @yaml_content = ''
      @haml_content = ''

      dash_lines = 0
      mode = :yaml

      @full_content.each_line do |line|
        if ( line.strip == '---' )
          dash_lines = dash_lines +1
        end
        if ( mode == :yaml )
          @yaml_content << line
        else
          @haml_content << line
        end
        if ( dash_lines == 2 )
          mode = :haml
        end
      end

      if ( dash_lines == 0 )
        @haml_content = @yaml_content
        @yaml_content = ''
      end

      @front_matter = YAML.load( @yaml_content ) || {}
    end

    def do_render(site, page=nil, content='')
      read
      page ||= self
      haml_engine = Haml::Engine.new( @haml_content ) 
      context = {
        :site=>site,
        :page=>page,
        :content=>content,
      }
      begin
        rendered = haml_engine.render( nil, context )
      rescue =>e
        puts e
      end
    end

    def layout
      @front_matter['layout']
    end

    def method_missing(sym, *args)
      return super unless @front_matter[sym.to_s]
      @front_matter[sym.to_s]
    end


  end
end
