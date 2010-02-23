require 'find'
require 'haml'
require 'sass'
require 'ostruct'
require 'hpricot'
require 'rss'

require 'haml/helpers'

module Haml::Helpers
  def html_to_text(str)
    str.gsub( /<[^>]+>/, '' )
  end

  def summarize(text, numwords=20)
    text.split()[0, numwords].join(' ')
  end

  def fully_qualify_urls(base_url, text)
    doc = Hpricot( text )
 
    doc.search( "//a" ).each do |a|
      a['href'] = fix_url( base_url, a['href'] )
    end
    doc.search( "//link" ).each do |link|
      link['href'] = fix_url( base_url, link['href'] )
    end
    doc.search( "//img" ).each do |img|
      img['src'] = fix_url( base_url, img['src'] )
    end
    return doc.to_s
  end

  def fix_url(base_url, url)
    return url unless ( url =~ /^\// )
    "#{base_url}#{url}"
  end

end

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
    attr_reader :config

    def initialize(dir)
      @pages = {}
      @dir = dir
      @output_dir = File.join( dir, '_site' )
      @config = {}
      @layouts = {}
      load_config
      load_layouts
    end

    def pages
      @pages.values
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
            @pages[path] = HamlPage.new( path, output_path( path, '.haml' ), url_path( path, '.haml' ) )
          elsif ( path =~ /\.sass$/ )
            @pages[path] = SassPage.new( path, output_path( path, '.sass' ) + '.css', url_path( path, '.sass' ) + '.css' )
          elsif ( File.file?( path ) )
            @pages[path] = CopyFile.new( path, output_path( path ), url_path( path ) )
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

    def url_path(path, ext=nil)
      url_path = output_path( path, ext )[ @output_dir.size .. -1 ]
    end

    def load_config
      load_yamls
    end

    def load_yamls
      Dir[ File.join( @dir, '_config', '*.yml' ) ].each do |yaml_path|
        data = YAML.load( File.read( yaml_path ) )
        name = File.basename( yaml_path, '.yml' )
        @config[name] = massage_yaml( data )
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

    def apply_plugins
      Dir[ File.join( @dir, '_plugins', '*.rb' ) ].each do |rb_path|
        site_root = @dir
        output_root = @output_dir
        begin
          eval File.read( rb_path )
          #data = eval File.read( rb_path )
          #name = File.basename( rb_path, '.rb' )
          #@config[name] = data
        rescue => e
          puts e
          puts e.backtrace
        end
      end
    end

    def load_layouts
      Dir[ File.join( @dir, '_layouts', '*.haml' ) ].each do |layout_path|
        name = File.basename( layout_path, '.haml' )
        name = File.basename( name, '.html' )
        @layouts[ name ] = HamlPage.new( layout_path, nil, nil )
      end
    end

    def method_missing(sym, *args)
      if ( sym.to_s =~ /^(.*)=$/ )
        puts "site[#{$1}]=#{args[0]}"
        @config[$1] = args[0]
      else
        return super unless @config[sym.to_s]
        @config[sym.to_s]
      end
    end

    def generate()
      scan()
      apply_plugins()
      @pages.values.each do |page|
        if ( page.modified?( self ) )
          $stderr.puts "generating #{page.output_path}"
          rendered = page.render( self.config )
          cur = page
          while ( ! cur.nil? && ! cur.layout.nil? )
            cur = @layouts[ cur.layout.to_s ]
            rendered = cur.render( self.config, page, rendered )
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
    attr_reader :url
    attr_reader :extra_options

    def initialize(path, output_path, url)
      @path = path
      @output_path = output_path
      @url = url
      @extra_options = {}
    end

    def prepare()
      return if output_path.nil?
      FileUtils.mkdir_p( File.dirname( output_path ) )
    end

    def render(config, page=nil, content='')
      prepare
      do_render(config, page, content)
    end

    def do_render(config, page=nil, content='')
      puts "render(config) not implemented"
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
    def initialize(path, output_path, url)
      super( path, output_path, url )
    end

    def do_render(config, page=nil, content='')
      File.read( path )
    end

    def layout
      nil
    end
  end

  class SassPage < Renderable
    def initialize(path, output_path, url)
      super( path, output_path, url )
    end

    def do_render(config, page=nil, content=nil)
      sass_engine = Sass::Engine.new( File.read( path ) )
      sass_engine.render
    end

    def layout
      nil
    end
  end

  class HamlPage < Renderable
    attr_accessor :front_matter
    def initialize(path, output_path, url)
      super( path, output_path, url )
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

    def do_render(config, page=nil, content='')
      read
      page ||= self
      haml_engine = Haml::Engine.new( @haml_content ) 
      context = {
        :page=>page,
        :content=>content,
      }.merge(config)
      begin
        rendered = haml_engine.render( nil, context )
      rescue =>e
        puts e
        puts e.backtrace
      end
    end

    def layout
      @front_matter['layout']
    end

    def method_missing(sym, *args)
      if ( sym.to_s =~ /^(.*)=$/ )
        puts "page[#{$1}]=#{args[0]}"
        @extra_options[$1] = args[0]
      else
        @front_matter[sym.to_s] || @extra_options[sym.to_s]
      end
    end


  end
end
