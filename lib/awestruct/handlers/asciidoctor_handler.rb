require 'awestruct/handler_chain'
require 'awestruct/handlers/base_tilt_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/layout_handler'
require 'awestruct/handlers/template/asciidoc'
require 'yaml'

require 'tilt'

module Awestruct
  module Handlers

    class AsciidoctorMatcher
      def match(path)
        engine = Tilt[path]
        engine == Tilt::AsciidoctorTemplate
      end
    end

    class AsciidoctorHandler < BaseTiltHandler

      CHAIN = Awestruct::HandlerChain.new( Awestruct::Handlers::AsciidoctorMatcher.new(),
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::AsciidoctorHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )

        @front_matter = {}
      end


      def front_matter
        parse_header()
        @front_matter
      end

      def raw_content
        parse_header()
        super
      end

      def rendered_content(context, with_layouts)
        parse_header()
        types = [String, Numeric, TrueClass, FalseClass, Array]
        @front_matter.merge!(context.page.inject({}) do |hash, (k,v)|
          hash[k.to_s] = v if not k.to_s.start_with?('__') and types.detect { |t| v.kind_of? t }
          hash
        end)
        super
      end

      def options
        opts = super
        if opts[:attributes].nil?
          opts[:attributes] = @front_matter 
        else
          opts[:attributes] = opts[:attributes].merge @front_matter
        end
        opts[:attributes]['awestruct'] = true
        opts[:attributes]['awestruct-version'] = Awestruct::VERSION
        opts
      end

      def content_line_offset
        parse_header()
        @content_line_offset
      end

      def inherit_front_matter(page)
        parse_header()
        page.inherit_front_matter_from(@front_matter)
      end

      def parse_header
        return if @parsed_parts

        parse_front_matter
        if content_line_offset == 0
          content = delegate.raw_content
          unless content.nil?
            @front_matter = parse_document_attributes(content)
            @parsed_parts = true
          end
        end
      end

      def parse_document_attributes(content)
        template = Tilt::new(delegate.path.to_s, delegate.content_line_offset + 1, options)
        template.parse_headers(content, /^awestruct\-/).inject({}) do |hash, (k,v)|
          unless v.nil?
            hash[k] = v.empty? ? v : YAML.load(v)
          end
          hash
        end
      end

      def parse_front_matter
        return if ( @parsed_parts && ! delegate.stale? )

        full_content = delegate.raw_content
        full_content.force_encoding(site.encoding) if site.encoding
        yaml_content = ''

        dash_lines = 0
        mode = :yaml

        @raw_content = ''
        @content_line_offset = 0

        full_content.each_line do |line|
          if ( line.strip == '---' )
            dash_lines = dash_lines +1
          end
          if ( mode == :yaml )
            @content_line_offset += 1
            yaml_content << line
          else
            @raw_content << line
          end
          if ( dash_lines == 2 )
            mode = :page
          end
        end
  
        if ( dash_lines == 0 )
          @raw_content = yaml_content
          yaml_content = ''
          @content_line_offset = 0
        elsif ( mode == :yaml )
          @raw_content = nil
          @content_line_offset = -1
        end

        begin
          @front_matter = YAML.load( yaml_content ) || {}
        rescue => e
          puts "could not parse #{relative_source_path}"
          raise e
        end

        @parsed_parts = true

      end
    end

  end
end

require 'awestruct/handlers/template/asciidoc'
Tilt::register Tilt::AsciidoctorTemplate, '.ad', '.adoc', '.asciidoc'
