require 'rdiscount'

module Awestruct

  module Markdownable
    def render(context)
      rendered = ''
      doc = RDiscount.new( context.interpolate_string( raw_page_content ) )
      doc.to_html
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end
  end

end
