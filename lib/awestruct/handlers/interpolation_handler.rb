require 'awestruct/util/exception_helper'
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
          ExceptionHelper.log_building_error e, relative_source_path
          c = delegate.raw_content
        end
        c

      end
    end
  end
end
