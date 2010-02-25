
module Awestruct
  module Extensions

    class Indexifier
      def execute(site)
        site.pages.each do |page|
          if ( page.output_path =~ /^(.*\/)?index.html$/ )
            puts "skipping #{page.output_path}"
          else
            page.output_path = page.output_path.gsub( /.html$/, '/index.html' )
          end
        end
      end
    end

  end
end
