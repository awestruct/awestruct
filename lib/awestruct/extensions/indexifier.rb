module Awestruct
  module Extensions
    class Indexifier

      def initialize(exclude_regex_paths = [])
        @exclude_regex_paths = exclude_regex_paths
      end

      def execute(site)
        site.pages.each do |page|
          if ( page.inhibit_indexifier ||  excluded_path(page) || ( page.output_path =~ /^(.*\/)?index.html$/ ) )
            # skip it!
          else
            page.output_path = page.output_path.gsub( /.html$/, '/index.html' )
          end
        end
      end

      def excluded_path(page)
        if (@exclude_regex_paths == nil)
          return false
        else
          @exclude_regex_paths.each do |regex_path|
             if (page.output_path.match(regex_path) != nil)
               return true
             end
          end
          return false
       end
      end

    end
  end
end
