require 'rdiscount'

module Awestruct

  module Rdiscountable
    def render(context)
      rendered = ''

      begin
        options = { }

        unless self.options.nil?
          options.merge!(self.options)
        end

        doc = RDiscount.new(context.interpolate_string( raw_page_content ))

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

