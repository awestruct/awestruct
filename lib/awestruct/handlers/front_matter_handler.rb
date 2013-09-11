require 'awestruct/handlers/base_handler'

require 'yaml'

module Awestruct
  module Handlers
    class FrontMatterHandler < BaseHandler

      def initialize(site, delegate)
        super
        @parsed_parts = false
      end

      def front_matter
        parse_parts()
        @front_matter
      end

      def raw_content
        parse_parts()
        @raw_content
      end

      def rendered_content(context, with_layouts)
        parse_parts()
        @raw_content
      end

      def content_line_offset
        parse_parts()
        @content_line_offset
      end

      def inherit_front_matter(page)
        page.inherit_front_matter_from( front_matter )
        super
      end

      private

      def parse_parts
        return if ( @parsed_parts && ! delegate.stale? )

        full_content = delegate.raw_content

        #if force_encoding is supported then set to charset defined in site config
        full_content.force_encoding(site.encoding) if (site.encoding && full_content.respond_to?(:force_encoding))

        yaml_content = ''

        dash_lines = 0
        mode = :yaml

        @raw_content = nil
        @content_line_offset = 0

        first_line = true
        full_content.each_line do |line|
          if line.rstrip == '---' && mode == :yaml
            unless first_line
              @content_line_offset += 1
              yaml_content << line
              mode = :page
              next
            end
          elsif first_line
            mode = :page
          end

          if mode == :yaml
            @content_line_offset += 1
            yaml_content << line
          elsif @raw_content.nil?
            @raw_content = line
          else
            @raw_content << line
          end
          first_line = false
        end
  
        if mode == :yaml
          @raw_content = nil
          @content_line_offset = -1
        end

        begin
          @front_matter = yaml_content.empty? ? {} : (YAML.load yaml_content)
        rescue => e
          $LOG.error "could not parse #{relative_source_path}" if $LOG.error?
          raise e
        end

        @parsed_parts = true

      end

    end
  end
end
