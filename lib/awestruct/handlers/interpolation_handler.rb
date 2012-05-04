
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
        return content unless site.interpolate

        content = content.gsub( /\\/, '\\\\\\\\' )
        content = content.gsub( /\\\\#/, '\\#' )
        content = content.gsub( '@', '\@' )
        content = "%@#{content}@"

        context.instance_eval( content )
      end

    end
  end
end
