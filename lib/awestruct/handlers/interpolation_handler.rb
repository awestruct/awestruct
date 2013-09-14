
require 'awestruct/handlers/base_handler'

module Awestruct
  module Handlers
    class InterpolationHandler < BaseHandler

      def initialize(site, delegate)
        super( site, delegate )
      end

      def rendered_content(context, with_layouts=true)
        content = delegate.raw_content

        return nil if content.nil?
        return content unless front_matter.fetch('interpolate', site.interpolate)

        content = content.gsub( /\\/, '\\\\\\\\' )
        content = content.gsub( /\\\\#/, '\\#' )
        content = content.gsub( /#(?!\{)/, '\#' )
        content = content.gsub( '@', '\@' )
        content = "%@#{content}@"
        begin
          c = context.instance_eval( content )
        rescue Exception => e # Don't barf all over ourselves if an exception is thrown
          $LOG.error "Exception thrown interpolating content. #{e.to_s}" if $LOG.error?
          $LOG.error e.backtrace.join("\n") if $LOG.error?
          c = delegate.raw_content
        end
        c

      end
    end
  end
end
