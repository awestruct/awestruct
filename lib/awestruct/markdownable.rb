require 'bluecloth'

module Awestruct

  module Markdownable
    def render(context)
      rendered = ''
      begin
        bluecloth_options = { :smartypants => true }

        unless self.options.nil?
          bluecloth_options.merge!({ :smartypants => false }) if self.options[:html_entities] == false
        end

        doc = BlueCloth.new( context.interpolate_string( raw_page_content ), bluecloth_options )
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
