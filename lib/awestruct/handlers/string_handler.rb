require 'awestruct/handlers/base_handler'

module Awestruct
  module Handlers
    class StringHandler < BaseHandler


      def initialize(site, content, output_extension='.html')
        super( site )
        @content = content
        @output_extension = output_extension
      end

      def output_extension
        @output_extension
      end


      def raw_content
        @content
      end

      def rendered_content(context, with_layouts=true)
        raw_content
      end

    end
  end
end
