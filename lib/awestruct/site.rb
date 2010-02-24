require 'ostruct'

module Awestruct
  class Site < OpenStruct

    attr_reader :layouts
    attr_reader :context

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
end
