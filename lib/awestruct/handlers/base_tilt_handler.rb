require 'awestruct/handlers/base_handler'

require 'tilt'

module Awestruct
  module Handlers
    class BaseTiltHandler < BaseHandler

      def initialize(site, delegate)
        super( site, delegate )
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
        base = File.basename( source_file_name, File.extname( source_file_name ))
        return File.basename( base, File.extname( base ) ) if double_extension?
        return base
      end

      def output_filename
        simple_name + output_extension
      end

      def input_extension
        File.extname( source_file_name )
      end

      def output_extension
        return File.extname( File.basename( source_file_name, File.extname( source_file_name ))) if double_extension?

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
        if !site[:content_syntax].nil?
          syntax = site[:content_syntax][extension]
          return syntax.to_sym unless syntax.nil?
        end

        return extension.to_sym
      end

      def options
        opts = {}

        engine_name = Tilt[path].name.gsub(/(Tilt|:|Template)/i, '').downcase.to_sym
        engine_options = site[engine_name]
        unless engine_options.nil?
          if engine_options.has_key? 'default'
            opts.merge! engine_options['default']
            if engine_options.has_key? output_extension[1..-1]
              opts.merge! engine_options[output_extension[1..-1]]
            end
          else
            opts.merge! engine_options
          end
        end

        # config overrides for specific file extension if different from engine name
        extension = input_extension[1..-1].to_sym
        unless engine_name == extension
          extension_options = site[extension] unless site[extension].nil?
          unless extension_options.nil?
            if extension_options.has_key? 'default'
              opts.merge! extension_options['default']
              if extension_options.has_key? output_extension[1..-1]
                opts.merge! extension_options[output_extension[1..-1]]
              end
            else
              opts.merge! extension_options
            end
          end
        end

        return opts
      end

      def rendered_content(context, with_layouts=true)
        $LOG.debug "invoking tilt for #{delegate.path.to_s} with_layouts = #{with_layouts}" if $LOG.debug?
        template = Tilt::new(delegate.path.to_s, delegate.content_line_offset + 1, options) { |engine|
            delegate.rendered_content( context, with_layouts )
        }
        template.render( context )
      end

    end
  end
end
