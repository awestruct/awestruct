require 'ostruct'

module Awestruct
  class Site < OpenStruct

    attr_reader :dir
    attr_reader :output_dir
    attr_reader :tmp_dir

    attr_reader   :layouts
    attr_accessor :pages

    def initialize(config)
      super({})

      @dir = config.input_dir
      @output_dir = config.output_dir
      @tmp_dir = config.tmp_dir

      FileUtils.mkdir_p( @output_dir )
      FileUtils.mkdir_p( @tmp_dir )

      @pages   = []
      @layouts = {}
    end

    def has_page?(path)
      ! pages.find{|e| e.source_path == path}.nil?
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

    def apply_plugins
      Dir[ File.join( @dir, '_plugins', '*.rb' ) ].each do |rb_path|
        site_root = @dir
        output_root = @output_dir
        begin
          eval File.read( rb_path )
        rescue => e
          puts e
          puts e.backtrace
        end
      end
    end

  end
end
