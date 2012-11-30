
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'

require 'less'

module Awestruct
  module Handlers
    class LessHandler < BaseHandler

      CHAIN = Awestruct::HandlerChain.new( /\.less$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::LessHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.less' )
      end

      def output_filename
        simple_name + '.css'
      end

      def rendered_content(context, with_layouts=true)
        load_paths = [File.dirname( context.page.source_path )]
        less_parser = Less::Parser.new :paths => load_paths, :filename => context.page.source_path
        less_parser.parse( raw_content ).to_css
      end

    end
  end
end
