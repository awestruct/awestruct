
require 'awestruct/handlers/base_handler'

require 'haml'

module Awestruct
  module Handlers
    class HamlHandler < BaseHandler

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( self.path, "#{output_extension}.haml" )
      end

      def output_filename
        return File.basename( relative_source_path, '.haml' ) unless relative_source_path.nil?
        nil
      end

      def output_extension
        File.extname( File.basename( path, '.haml' ) )
      end

      def rendered_content(context, with_layouts=true)
        options = context.site.haml? ? context.site.haml : {}
        options = options.inject({}){ |hash,(key,value)| 
          hash[key.to_sym] = value
          hash
        }
        options[:relative_source_path] = context.page.relative_source_path
        options[:filename] = delegate.path.to_s
        options[:line]     = delegate.content_line_offset + 1
        options[:site] = context.site
        haml_engine = Haml::Engine.new( delegate.raw_content, options )
        haml_engine.render( context )
      end

    end
  end
end
