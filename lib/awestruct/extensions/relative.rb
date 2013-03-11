require 'pathname'

module Awestruct
  module Extensions
    module Relative

      def relative(href, p = page)
        begin
          Pathname.new(href).relative_path_from(Pathname.new(File.dirname(p.output_path))).to_s
        rescue Exception => e
          $LOG.error "#{e}" if $LOG.error?
          $LOG.error "#{e.backtrace}" if $LOG.error?
        end
      end

    end
  end
end
