require 'pathname'

module Awestruct
  module Extensions
    module Relative
      def relative(href)
        Pathname.new(href).relative_path_from(Pathname.new(File.dirname(page.output_path))).to_s
      end
    end
  end
end