
require 'awestruct/handlers/base_handler'
require 'redcloth'

module Awestruct
  module Handlers
    class TextileHandler < BaseHandler

      def initialize(site, delegate)
        super( site, delegate )
      end

      def simple_name
        File.basename( relative_source_path, '.textile' ) 
      end

      def output_filename
        File.basename( relative_source_path, '.textile' ) + '.html'
      end

      def output_extension
        '.html'
      end

      def content_syntax
        :textile
      end

      def rendered_content(context, with_layouts=true)
        rendered = ''
        # security and rendering restrictions
        # ex. site.textile = ['no_span_caps']
        restrictions = (site.textile || []).map { |r| r.to_sym }
        # a module of rule functions is included in RedCloth using RedCloth.send(:include, MyRules)
        # rule functions on that module are activated by setting the property site.textile_rules
        # ex. site.textile_rules = ['emoticons']
        rules = context.site.textile_rules ? context.site.textile_rules.map { |r| r.to_sym } : []
        RedCloth.new( delegate.rendered_content( context, with_layouts ), restrictions ).to_html(*rules)
      end

    end
  end
end
