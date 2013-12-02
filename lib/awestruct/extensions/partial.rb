module Awestruct
  module Extensions
    module Partial

      def partial(path, params = {})
        filename = File.join( '_partials', path )

        if !File.exists?( filename )
          $LOG.error "Could not find #{filename}" if $LOG.error?
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
