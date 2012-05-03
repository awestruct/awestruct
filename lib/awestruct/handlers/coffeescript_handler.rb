
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'

require 'coffee-script'

module Awestruct
  module Handlers
    class CoffeescriptHandler < BaseHandler


      CHAIN = Awestruct::HandlerChain.new( /\.coffee$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::CoffeescriptHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.coffee' ) 
      end

      def output_filename
        File.basename( relative_source_path, '.coffee' ) + '.js'
      end

      def output_extension
        '.js'
      end

      def content_syntax
        :coffeescript
      end

      def rendered_content(context, with_layouts=true)
        CoffeeScript.compile( delegate.rendered_content( context, with_layouts ) )
      end

    end
  end
end
