
require 'awestruct/handlers/base_handler'

module Awestruct
  module Handlers
    class PageDelegatingHandler < BaseHandler

      attr_accessor :page

      def initialize(site, page)
        super( site )
        @page = page
      end

      def path
        page.source_path
      end

      def inherit_front_matter(outer_page)
        #page.prepare!
        #page.handler.inherit_front_matter( outer_page )
        @page.handler.inherit_front_matter(outer_page)
      end

      def output_path
        page.output_path
      end

      def relative_source_path
        page.relative_source_path
      end

      def output_extension
        page.output_extension
      end

      def stale?
        page.stale?
      end

      def input_mtime(ignored)
        page.input_mtime
      end

      def raw_content
        page.raw_content
      end

      def rendered_content(context_ignored, with_layouts_ignored=true)
        page.content( true )
      end

    end
  end
end
