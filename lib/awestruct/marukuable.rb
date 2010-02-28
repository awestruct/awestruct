require 'maruku'

module Awestruct

  module Marukuable
    def render(context)
      rendered = ''
      begin
        doc = Maruku.new( context.interpolate_string( raw_page_content ) )
        rendered = doc.to_html
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end

    def content
      context = Awestruct::Engine.create_context( site, self )
      render( context )
    end
  end

end
