module Awestruct
  module Extensions
    class Indexifier

      def initialize(exclude_regex_paths = [])
        @exclude_regex_paths = exclude_regex_paths
        @exclude_regex_paths << /^(.*\/)?index.html$/
      end

      def execute(site)
        site.pages.each do |page|
          if ( page.inhibit_indexifier ||  Regexp.union(@exclude_regex_paths).match(page.output_path) )
            # skip it!
          else
            page.output_path = page.output_path.gsub( /.html$/, '/index.html' )
          end
        end
      end 
    end
  end
end
