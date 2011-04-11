module Awestruct
  module Extensions
    class Atomizer
      def initialize(entries_name, output_path, opts={})
        @entries_name = entries_name
        @output_path = output_path
        @num_entries = opts[:num_entries] || 50
      end

      def execute(site)
        entries = site.send( @entries_name ) || []
        unless ( @num_entries == :all )
          entries = entries[0, @num_entries]
        end
        input_page = File.join( File.dirname(__FILE__), 'template.atom.haml' )
        page = site.engine.load_page( input_page )
        page.date = page.timestamp unless page.timestamp.nil?
        page.output_path = @output_path
        page.entries = entries
        page.title = site.title || site.base_url
        site.pages << page
      end

    end
  end
end
