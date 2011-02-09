module Awestruct

  module Textilable
    def render(context)
      rendered = ''
      begin
        rendered = RedCloth.new( context.interpolate_string( raw_page_content ) ).to_html
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end

    def content
      context = site.engine.create_context(self)
      render(context)
    end
  end

end
