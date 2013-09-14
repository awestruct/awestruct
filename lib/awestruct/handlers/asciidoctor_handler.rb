require 'awestruct/handler_chain'
require 'awestruct/handlers/base_tilt_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/layout_handler'
require 'awestruct/handlers/template/asciidoc'
require 'yaml'

require 'tilt'

module Awestruct
  module Handlers

    class AsciidoctorTiltMatcher < TiltMatcher
      # Use a lightweight lookup to avoid loading Tilt templates for
      # non-matching paths. Once we are sure this is a match, then
      # attempt to load the Tilt template for AsciiDoc files.
      def match(path)
        # formal lookup as implemented in Tilt
        pattern = File.basename(path.downcase)
        registered = false
        until pattern.empty? || (registered = Tilt.registered?(pattern))
          # shave pattern down to next extension
          pattern = pattern.sub(/^[^.]*\.?/, '')
        end
        if registered && (Tilt.mappings[pattern] || []).include?(Tilt::AsciidoctorTemplate)
          begin
            Tilt[File.basename(path)]
          rescue LoadError
            # swallowing error as it will be picked up again by primary TiltHandler
            false
          end
        else
          false
        end
      end
    end

    class AsciidoctorHandler < BaseTiltHandler

      CHAIN = Awestruct::HandlerChain.new( Awestruct::Handlers::AsciidoctorTiltMatcher.new(),
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::AsciidoctorHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )

        @site = site
        @front_matter = {}
      end


      def front_matter
        parse_header()
        if @delegate
          @front_matter.update @delegate.front_matter
          # push front matter forward as well
          @delegate.front_matter.replace @front_matter
          @front_matter
        end
      end

      def raw_content
        parse_header()
        @delegate.raw_content if @delegate
      end

      def content_line_offset
        parse_header()
        @delegate.content_line_offset if @delegate
      end

      def rendered_content(context, with_layouts)
        parse_header()
        front_matter_ref = front_matter
        types = [String, Numeric, TrueClass, FalseClass, Array]
        front_matter_ref.update(context.page.inject({}) {|hash, (k,v)|
          hash[k.to_s] = v if not k.to_s.start_with?('__') and types.detect { |t| v.kind_of? t }
          hash
        })
        if with_layouts && !context.page.layout
          front_matter_ref['header_footer'] = true
        end
        super
      end

      def options
        opts = super
        opts[:attributes] ||= {}
        opts[:attributes].update(@front_matter.inject({}) {|collector, (key,val)|
          collector["page-#{key}"] = "#{val}@"
          collector
        })
        # Keep only values that can be coerced to as string
        types = [String, Numeric, TrueClass, FalseClass, Date, Time]
        opts[:attributes].update(@site.inject({}) {|collector, (key,val)|
          collector["site-#{key}"] = "#{val}@" if types.detect {|t| val.kind_of? t }
          collector
        })
        opts[:attributes]['awestruct'] = true
        opts[:attributes]['awestruct-version'] = Awestruct::VERSION
        if @front_matter['header_footer']
          opts[:header_footer] = true
        end
        path_expanded = File.expand_path path
        opts[:attributes]['docdir'] = File.dirname path_expanded
        opts[:attributes]['docfile'] = path_expanded
        opts[:attributes]['docname'] = simple_name
        path_mtime = path.mtime
        opts[:attributes]['docdate'] = docdate = path_mtime.strftime('%Y-%m-%d')
        opts[:attributes]['doctime'] = doctime = path_mtime.strftime('%H:%M:%S %Z')
        opts[:attributes]['docdatetime'] = %(#{docdate} #{doctime})
        # TODO once Asciidoctor 1.5.0 is release, we should set the base_dir as a jail
        # we can't do this before 1.5.0 due to a bug in how includes are resolved
        if (Object.const_defined? 'Asciidoctor') && Asciidoctor::VERSION >= '1.5.0'
          opts[:base_dir] ||= @site.config.dir
        end
        opts
      end

      def content_line_offset
        parse_header()
        @content_line_offset
      end

      def inherit_front_matter(page)
        parse_header()
        page.inherit_front_matter_from(front_matter)
        super
      end

      def parse_header
        return if @parsed_parts

        content = delegate.raw_content
        unless content.nil?
          @front_matter = parse_document_attributes(content)
        end
        @parsed_parts = true
      end

      def parse_document_attributes(content)
        warned = false
        template = Tilt::new(delegate.path.to_s, delegate.content_line_offset + 1, options)
        template.parse_headers(content, /^(?:page|awestruct)\-(?=.)/).inject({'interpolate' => false}) do |hash, (k,v)|
          unless v.nil?
            hash[k] = v.empty? ? v : YAML.load(v)
            if hash[k].kind_of? Time
              # use DateTime to preserve timezone information
              hash[k] = DateTime.parse(v)
            end
          end
          hash
        end
      end

    end

  end
end

require 'awestruct/handlers/template/asciidoc'
Tilt::register Tilt::AsciidoctorTemplate, '.ad', '.adoc', '.asciidoc'
