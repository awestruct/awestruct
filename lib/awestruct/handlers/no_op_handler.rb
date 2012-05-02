
require 'awestruct/handlers/base_handler'

module Awestruct
  module Handlers
    class NoOpHandler < BaseHandler

      def initialize(site)
        super( site )
      end

      def output_filename
        nil
      end

      def relative_source_path
        nil
      end

      def stale?
        false
      end

      def raw_content
        nil
      end

      def rendered_content(context, with_layouts=true)
        nil
      end

    end
  end
end
