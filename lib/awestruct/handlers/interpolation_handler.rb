
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
        content = content.gsub( Regexp.new('#(?!{)'), '\#' ) if ruby_19?
        content = content.gsub( '@', '\@' )
        content = "%@#{content}@"
        begin
          c = context.instance_eval( content )
        rescue Exception => e # Don't barf all over ourselves if an exception is thrown
          $stderr.puts "Exception thrown interpolating content. #{e.to_s}"
          $stderr.puts e.backtrace
          c = delegate.raw_content
        end
        c

      end

      def ruby_19?
        @is_ruby_19 ||= (::RbConfig::CONFIG['ruby_version'] =~ %r(^1\.9))
      end

    end
  end
end
