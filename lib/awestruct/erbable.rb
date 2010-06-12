require 'sass'

require 'compass'

module Awestruct
  module Erbable

    def render(context)
      erb = ERB.new( raw_page_content )
      context.evaluate_erb( erb )
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end

  end
end
