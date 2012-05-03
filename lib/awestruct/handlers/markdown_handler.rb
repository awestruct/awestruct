
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'
require 'awestruct/handlers/layout_handler'
require 'rdiscount'

module Awestruct
  module Handlers
    class MarkdownHandler < BaseHandler


      CHAIN = Awestruct::HandlerChain.new( /\.md$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::MarkdownHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.md' ) 
      end

      def output_filename
        File.basename( relative_source_path, '.md' ) + '.html'
      end

      def output_extension
        '.html'
      end

      def content_syntax
        :markdown
      end

      def rendered_content(context, with_layouts=true)
        doc = RDiscount.new( raw_content )
        doc.to_html
      end

    end
  end
end
