module Awestruct

  module CoffeeScriptable
    def render(context)
      CoffeeScript.compile context.interpolate_string( raw_page_content ) #, {:no_wrap => true}
    end

    def content
      context = site.engine.create_context(self)
      render(context)
    end
  end

end
