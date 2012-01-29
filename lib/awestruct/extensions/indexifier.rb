module Awestruct
  module Extensions
    class Indexifier

      def execute(site)
        site.pages.each do |page|
          if ( page.inhibit_indexifier || ( page.output_path =~ /^(.*\/)?index.html$/ ) )
            # skip it!
          else
            page.output_path = page.output_path.gsub( /.html$/, '/index.html' )
          end
        end
      end

    end
  end
end
