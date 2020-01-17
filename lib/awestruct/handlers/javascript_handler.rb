require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'

module Awestruct
  module Handlers
    class JavascriptHandler < BaseHandler


      CHAIN = Awestruct::HandlerChain.new( /\.js$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::JavascriptHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path || path, '.js' )
      end

      def output_filename
        File.basename( relative_source_path || path)
      end

      def output_extension
        '.js'
      end

      def content_syntax
        :javascript
      end

      def rendered_content(context, with_layouts=false)
        delegate.rendered_content( context, with_layouts )
      end

    end
  end
end

