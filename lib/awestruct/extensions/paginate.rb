

module Awestruct
  module Extensions
    class Paginate

      def initialize(prop_name, input_path, opts={})
        @prop_name  = prop_name
        @input_path = input_path
        @per_page   = opts[:per_page] || 20
      end

      def execute(site)
        removal_path = nil
        all = site.send( @prop_name )
        i = 1
        all.each_slice( @per_page ) do |slice|
          page = site.engine.find_and_load_site_page( @input_path )
          removal_path ||= page.output_path
          page.send( "#{@prop_name}=", slice )
          if ( i == 1 )
            page.output_path = File.join( File.dirname( @input_path ), File.basename( @input_path ) + ".html" )
          else
            page.output_path = File.join( File.dirname( @input_path ), "page#{i}.html" )
          end
          page.paginate_generated = true
          site.pages << page
          i = i + 1
        end 

        site.pages.reject!{|page|
          ( ! page.paginate_generated && ( page.output_path == removal_path ) )
        }
      end
    end

  end
end
