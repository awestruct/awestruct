

module Awestruct
  module Extensions
    class Paginate

      def initialize(prop_name, input_path, opts={})
        @prop_name  = prop_name
        @input_path = input_path
        @per_page   = opts[:per_page] || 20
      end

      def execute(site)
        all = site.send( @prop_name )
        i = 0
        all.each_slice( @per_page ) do |slice|
          page = site.engine.load_site_page( @input_path )
          page.send( "#{@prop_name}=", slice )
          page.output_path = File.join( File.dirname( @input_path ), "page-#{i}.html" )
          site.pages << page
          i = i + 1
        end 
      end
    end

  end
end
