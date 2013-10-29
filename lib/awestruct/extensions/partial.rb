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

        Awestruct::Dependencies.top_page.site.partials ||= []
        Awestruct::Dependencies.top_page.site.partials << page
        Awestruct::Dependencies.track_dependency( page )

        page.content
      end

    end
  end
end
