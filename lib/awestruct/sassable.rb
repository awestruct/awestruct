require 'sass'

require 'compass'

module Awestruct
  module Sassable

    def render(context)
      sass_opts = {
        :load_paths => [
          File.dirname( self.source_path ),
          Compass::Frameworks['compass'].stylesheets_directory,
          Compass::Frameworks['blueprint'].stylesheets_directory,
        ],
      }
      sass_engine = Sass::Engine.new( raw_page_content, sass_opts )
      sass_engine.render
    end

    def output_extension
      'css'
    end

  end
end
