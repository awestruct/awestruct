module Awestruct

  module Hamlable
    def render(context)
      rendered = ''
      begin
        haml_engine = Haml::Engine.new( raw_page_content )
        rendered = haml_engine.render( context )
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end
  end

end
