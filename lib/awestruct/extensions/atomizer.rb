module Awestruct
  module Extensions
    class Atomizer
      def initialize(entries_name, output_path)
        @entries_name = entries_name
        @output_path = output_path
      end

      def execute(site)
        entries = site.send( @entries_name )
        input_page = File.join( File.dirname(__FILE__), 'template.atom.haml' )
        page = site.engine.load_page( input_page )
        page.output_path = @output_path
        page.entries = entries
        page.title = site.title || site.base_url
        site.pages << page
      end

    end
  end
end
