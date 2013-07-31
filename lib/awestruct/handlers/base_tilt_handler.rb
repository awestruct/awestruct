require 'awestruct/handlers/base_handler'

require 'tilt'

module Awestruct
  module Handlers

    class TiltMatcher
      # Returns the Tilt template class if a portion of the path is registered
      # to a Tilt template and the Tilt template can be loaded. Returns false
      # if no portions of the path are registered to a Tilt template or the
      # Tilt template cannot be loaded.
      def match(path)
        begin
          Tilt[File.basename(path)]
        rescue LoadError => e
          $LOG.warn(%(Copying #{path} to generated site without processing; missing required gem -- #{e.message.split(/ *-- */).last} (or equivalent)))
          false
        end
      end
    end

    class BaseTiltHandler < BaseHandler

      def initialize(site, delegate)
        super(site, delegate)
      end

      def source_file_name
        File.basename path
      end

      # HACK: if this is a double file name extension type
      # e.g. html.haml, xml.erb
      # move to default-site.yml?
      def double_extension?
        return true if input_extension =~ /haml|slim|erb|mustache/
      end

      def simple_name
        base = File.basename(source_file_name, File.extname(source_file_name))
        return File.basename(base, File.extname(base)) if double_extension?
        return base
      end

      def output_filename
        simple_name + output_extension
      end

      def input_extension
        File.extname(source_file_name)
      end

      def output_extension
        return File.extname(File.basename(source_file_name, File.extname(source_file_name))) if double_extension?

        template = Tilt[path]
        if !template.nil?
          mime = template.default_mime_type
          if !mime.nil?
            return '.js' if mime.eql? 'application/javascript'
            return '.html' if mime.eql? 'text/html'
            return '.xml' if mime.eql? 'text/xml'
            return '.css' if mime.eql? 'text/css'
            return '.html' # if all else falls trough
          end
        end
        return '.html'
      end

      def content_syntax
        # Check configuration for override, else convert extension to sym
        extension = input_extension[1..-1]
        if (!site[:content_syntax].nil? && !site[:content_syntax].empty?)
          syntax = site[:content_syntax][extension]
          return syntax.to_sym unless syntax.nil? or syntax.empty?
        end

        return extension.to_sym
      end

      def options
        opts = {}

        in_ext = input_extension[1..-1].to_sym
        out_ext = output_extension[1..-1].to_sym

        engine_name = Tilt[path].name.gsub(/(Tilt|:|Template)/i, '').downcase.to_sym

        # example: slim
        engine_opts = site[engine_name]
        unless engine_opts.nil?
          opts.merge! engine_opts
        end

        # example: slim|xml
        engine_opts_for_output = site["#{engine_name}|#{out_ext}"]
        unless engine_opts_for_output.nil?
          opts.merge! engine_opts_for_output
        end

        # config overrides for specific file extension if different from engine name
        unless engine_name == in_ext
          # example: adoc
          in_ext_opts = site[in_ext]
          unless in_ext_opts.nil?
            opts.merge! in_ext_opts
          end

          # example: adoc|xml
          in_ext_opts_for_output = site["#{in_ext}|#{out_ext}"]
          unless in_ext_opts_for_output.nil?
            opts.merge! in_ext_opts_for_output
          end
        end

        return opts
      end

      def rendered_content(context, with_layouts=true)
        $LOG.debug "invoking tilt for #{delegate.path.to_s} with_layouts = #{with_layouts}" if $LOG.debug?
        begin
          template = Tilt::new(delegate.path.to_s, delegate.content_line_offset + 1, options) { |engine|
            delegate.rendered_content(context, with_layouts)
          }
          return template.render(context)
        rescue LoadError => e
          $LOG.error "Could not load template library required for rendering #{delegate.path.to_s}, please see rendered output for more information" if $LOG.error?
          return "<h1>#{e.message}</h1><h2>Rendering file #{delegate.path.to_s} resulted in a failure.</h2><p>Backtrace: #{e.backtrace.join '<br>'}</p>"
        rescue Exception => e
          $LOG.error "An error during rendering #{delegate.path.to_s} occurred, please see rendered output for more information"  if $LOG.error?
          return "<h1>#{e.message}</h1><h2>Rendering file #{delegate.path.to_s} resulted in a failure.</h2><h3>Line: #{e.line if e.respond_to?(:line)}</h3><p>Backtrace: #{e.backtrace.join '<br>'}</p>"
        end
      end

    end
  end
end
