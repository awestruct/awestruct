
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'
require 'awestruct/handlers/layout_handler'

module Awestruct
  module Handlers
    class AsciidocHandler < BaseHandler

      CHAIN = Awestruct::HandlerChain.new( /\.(adoc|asciidoc)$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::AsciidocHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        p = File.basename( relative_source_path )
        File.basename( p, File.extname( p ) )
      end

      def output_filename
        simple_name + output_extension
      end

      def output_extension
        '.html' 
      end

      def content_syntax
        :asciidoc
      end

      def rendered_content(context, with_layouts=true)
        content = delegate.rendered_content( context, with_layouts )
        imagesdir = site.config.images_dir
        iconsdir = File.join(imagesdir, 'icons')
        conffile = File.join(site.config.config_dir, 'asciidoc.conf')
        confopt = File.exist?(conffile) ? '-f ' + conffile : ''
        content = execute_shell( [ "asciidoc -s -b html5 -a pygments -a icons",
                                   "-a iconsdir='#{iconsdir}'",
                                   "-a imagesdir='#{imagesdir}'",
                                   "#{confopt} -o - -" ].join( ' ' ),
                                 content)
        content.gsub( "\r", '' )
      end
    end
  end
end
