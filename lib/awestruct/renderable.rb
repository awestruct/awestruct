module Awestruct
  class Renderable < OpenStruct

    attr_reader :path
    attr_reader :output_path
    attr_reader :url

    def initialize(path, output_path, url)
      super( {} )
      @path        = path
      @output_path = output_path
      @url         = url
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
end
