module Awestruct

  module Hamlable
    def render(context)
      rendered = ''
      options = (site.haml || {}).inject({}){|h,(k,v)| h[k.to_sym] = v; h } 
      options[:relative_source_path] = context.page.relative_source_path
      options[:site] = site
      haml_engine = Haml::Engine.new( raw_page_content, options )
      haml_engine.render( context )
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end
  end

end
