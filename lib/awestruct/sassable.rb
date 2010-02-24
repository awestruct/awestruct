require 'sass'

module Awestruct
  module Sassable

    def render(context)
      sass_engine = Sass::Engine.new( raw_page_content )
      sass_engine.render
    end

    def output_extension
      'css'
    end

  end
end
