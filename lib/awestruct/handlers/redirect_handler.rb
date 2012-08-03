require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'

module Awestruct
  module Handlers
    class RedirectHandler < BaseHandler


      CHAIN = Awestruct::HandlerChain.new( /\.redirect$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::RedirectHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.redirect' ) 
      end

      def output_filename
        simple_name + output_extension
      end

      def output_extension
        '.html'
      end

      def content_syntax
        :text
      end

      def rendered_content(context, with_layouts=false)
        url = delegate.rendered_content( context, with_layouts ).strip
        %{<head><meta http-equiv="location" content="URL=#{url}" /></head>}
      end

    end
  end
end


