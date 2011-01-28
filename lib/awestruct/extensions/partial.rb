
module Awestruct
  module Extensions
    module Partial

      def partial(path)
        page = site.engine.load_site_page( File.join( '_partials', path ) )
        page.content if ( page )
      end

    end
  end

end
