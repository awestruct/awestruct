module Awestruct
  module Extensions
    class Gsub

      def initialize(pattern, replacement, options = {})
        @pattern = pattern
        @replacement = replacement
        @gsub_required = options[:gsub_required] || lambda { |site, page| page.output_path.end_with?(".html") }
      end

      def transform(site, page, rendered)
        if (@gsub_required.call(site, page))
          rendered = rendered.gsub(@pattern, @replacement)
        end
        rendered
      end

    end
  end
end
