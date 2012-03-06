module Awestruct

  module Textilable
    def render(context)
      rendered = ''
      # security and rendering restrictions
      # ex. site.textile = ['no_span_caps']
      restrictions = (site.textile || []).map { |r| r.to_sym }
      # a module of rule functions is included in RedCloth using RedCloth.send(:include, MyRules)
      # rule functions on that module are activated by setting the property site.textile_rules
      # ex. site.textile_rules = ['emoticons']
      rules = context.site.textile_rules ? context.site.textile_rules.map { |r| r.to_sym } : []
      RedCloth.new( context.interpolate_string( raw_page_content ), restrictions ).to_html(*rules)
    end

    def content
      context = site.engine.create_context(self)
      render(context)
    end
  end

end
