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
        File.basename( relative_source_path || path, '.redirect' ) 
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
        # should we auto-qualify the URL?
        # they can use #{site.base_url}/path currently
        #if url.start_with? '/'
        #  url = File.join(@site.base_url, url)
        #end
        %{<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0;url=#{url}"></head></html>}
      end

    end
  end
end


