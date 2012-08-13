
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/layout_handler'

require 'mustache'

module Awestruct
  module Handlers
    class MustacheHandler < BaseHandler

      CHAIN = Awestruct::HandlerChain.new( /\.mustache$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::MustacheHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( self.path, "#{output_extension}.mustache" )
      end

      def output_filename
        return File.basename( relative_source_path, ".mustache") unless relative_source_path.nil?
        nil
      end

      def output_extension
        File.extname( File.basename( path, ".mustache" ) )
      end

      def rendered_content(context, with_layouts=true)
        Mustache.render( delegate.raw_content, context )
      end

    end
  end
end
