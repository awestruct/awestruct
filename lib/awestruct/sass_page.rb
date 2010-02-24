module Awestruct
  class SassPage < Renderable
    def initialize(path, output_path, url)
      super( path, output_path, url )
    end

    def do_render(config, page=nil, content=nil)
      sass_engine = Sass::Engine.new( File.read( path ) )
      sass_engine.render
    end

  end
end
