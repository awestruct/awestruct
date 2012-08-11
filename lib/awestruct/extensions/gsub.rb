module Awestruct
  module Extensions
    class Gsub

      def initialize(pattern, replacement, options = {})
        @pattern = pattern
        @replacement = replacement.is_a?(Proc) ? replacement : lambda { |site, page| replacement }
        @gsub_required = lambdaize(options[:gsub_required])
      end

      def transform(site, page, rendered)
        if (@gsub_required.call(site, page))
          replacement = @replacement.call(site, page).to_s
          rendered = rendered.gsub(@pattern, replacement)
        end
        rendered
      end

      private

      def lambdaize(param)
        if param.nil?
          lambdaize([".html"])
        else
          if param.is_a?(Array)
            lambda { |site, page| param.any?{ |ext| page.output_path.end_with?(ext) } }
          else
            param
          end
        end
      end
    end
  end
end
