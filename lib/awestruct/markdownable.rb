require 'rdiscount'

module Awestruct

  module Markdownable
    def render(context)
      rendered = ''
      begin
        doc = RDiscount.new( context.interpolate_string( raw_page_content ) )
        rendered = doc.to_html
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end
  end

end
