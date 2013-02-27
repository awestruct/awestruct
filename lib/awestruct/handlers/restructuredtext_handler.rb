
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'
require 'awestruct/handlers/layout_handler'

require 'nokogiri'

module Awestruct
  module Handlers
    class RestructuredtextHandler < BaseHandler

      CHAIN = Awestruct::HandlerChain.new( /\.(rst)$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::RestructuredtextHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.rst' )
      end

      def output_filename
        simple_name + output_extension
      end

      def output_extension
        '.html' 
      end

      def content_syntax
        :rst
      end

      def rendered_content(context, with_layouts=true)
        content = delegate.rendered_content( context, with_layouts )

        hl = 1
        if front_matter['initial_header_level'].to_s =~ /^[1-6]$/
          hl = front_matter['initial_header_level']
        end
        rendered = ''
        begin
          doc = execute_shell( [ "rst2html",
                                 "--strip-comments",
                                 "--no-doc-title",
                                 " --initial-header-level=#{hl}" ].join(' '), 
                                 content )
          content = Nokogiri::HTML.fragment( doc ).at( '/html/body/div[@class="document"]' ).inner_html.strip
          content = content.gsub( "\r", '' )
        rescue => e
          puts e
          puts e.backtrace
        end
        content
      end
    end
  end
end
