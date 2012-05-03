
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'
require 'awestruct/handlers/layout_handler'
require 'org-ruby'

module Awestruct
  module Handlers
    class OrgmodeHandler < BaseHandler

      CHAIN = Awestruct::HandlerChain.new( /\.org$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::OrgmodeHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.org' ) 
      end

      def output_filename
        File.basename( relative_source_path, '.org' ) + '.html'
      end

      def output_extension
        '.html'
      end

      def content_syntax
        :orgmode
      end

      def rendered_content(context, with_layouts=true)
        Orgmode::Parser.new(super( context, with_layouts) ).to_html
      end

    end
  end
end
