
require 'awestruct/handlers/base_handler'

puts "RUBY_VERSION: " + ::Config::CONFIG['ruby_version'] 
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
        c = context.instance_eval( content )
        c

      end

      def ruby_19?
        @is_ruby_19 ||= (::Config::CONFIG['ruby_version'] =~ %r(^1\.9))
      end

    end
  end
end
