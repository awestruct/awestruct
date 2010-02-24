module Awestruct
  class VerbatimFile < Renderable
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
end
