require 'awestruct/util/exception_helper'
require 'pathname'

module Awestruct
  module Extensions
    module Relative

      def relative(href, p = page)
        begin
          # Ignore absolute links
          if href.start_with?("http://") || href.start_with?("https://")
            result = href
          else
            pathname = Pathname.new(href).relative_path_from(Pathname.new(File.dirname(p.output_path)))
            result = pathname.to_s
            result << '/' if pathname.extname.empty?
          end
          result
        rescue Exception => e
          ExceptionHelper.log_building_error e, p.relative_source_path
        end
      end

    end
  end
end
