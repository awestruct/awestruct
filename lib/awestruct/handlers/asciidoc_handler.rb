
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
        if !site.asciidoc? || !site.asciidoc.has_key?(:engine)
          site.asciidoc[:engine] = 'asciidoctor'
        end

        if !site.asciidoc.has_key?(:engine_loaded)
          if site.asciidoc[:engine] != 'system'
            require site.asciidoc[:engine]
          end
          site.asciidoc[:engine_loaded] = true
        end
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
        options = context.site.asciidoc

        content = delegate.rendered_content( context, with_layouts )
        if options[:engine] == 'system'
          imagesdir = site.config.images_dir
          iconsdir = File.join(imagesdir, 'icons')
          conffile = File.join(site.config.config_dir, 'asciidoc.conf')
          confopt = File.exist?(conffile) ? '-f ' + conffile : ''
          content = execute_shell( [ "asciidoc -s -b html5 -a pygments -a icons",
                                     "-a iconsdir='#{iconsdir}'",
                                     "-a imagesdir='#{imagesdir}'",
                                     "#{confopt} -o - -" ].join( ' ' ),
                                   content, false)
          content.gsub( "\r", '' )
        elsif options[:engine] == 'asciidoctor'
          opts = {
            :header_footer => false,
            :attributes => {
              'backend' => 'html5',
              'imagesdir' => site.config.images_dir,
              'stylesdir' => site.config.stylesheets_dir,
            }
          }
          if options.has_key? :templates
            opts[:template_dir] = options[:templates]
          end
          Asciidoctor::Document.new(content, opts).render
        else
          raise 'Unknown AsciiDoc engine: ' + options[:engine]
        end
      end
    end
  end
end
