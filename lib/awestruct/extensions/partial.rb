module Awestruct
  module Extensions
    module Partial

      def partial(path, params = {})
        filename = File.join( '_partials', path )

        if !File.exists?( filename )
          puts "no file #{filename} to include"
          return nil
        end

        page = site.engine.load_site_page( filename )

        return nil if !page

        params.each do |k,v|
          page.send( "#{k}=", v )
        end if params

        page.content
      end

    end
  end
end
