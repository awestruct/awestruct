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
            result = Pathname.new(href).relative_path_from(Pathname.new(File.dirname(p.output_path))).to_s
          end
          result
        rescue Exception => e
          ExceptionHelper.log_building_error e, p.relative_source_path
        end
      end

    end
  end
end
