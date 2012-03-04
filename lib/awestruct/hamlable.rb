module Awestruct

  module Hamlable
    def render(context)
      rendered = ''
      begin
        options = (site.haml || {}).inject({}){|h,(k,v)| h[k.to_sym] = v; h } 
        options[:relative_source_path] = context.page.relative_source_path
        options[:site] = site
        haml_engine = Haml::Engine.new( raw_page_content, options )
        rendered = haml_engine.render( context )
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end
  end

end
