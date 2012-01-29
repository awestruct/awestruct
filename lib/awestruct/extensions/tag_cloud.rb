module Awestruct
  module Extensions
    class TagCloud

      def initialize(tagged_items_property, output_path='tags', opts={})
        @tagged_items_property = tagged_items_property
        @output_path = output_path
        @layout = opts[:layout].to_s
        @title  = opts[:title] || 'Tags'
      end

      def execute(site)
        page = site.engine.load_page( File.join( File.dirname( __FILE__ ), 'tag_cloud.html.haml' ) )
        page.output_path = File.join( @output_path )
        page.layout = @layout
        page.title  = @title
        page.tags = site.send( "#{@tagged_items_property}_tags" ) || []
        site.pages << page
        site.send( "#{@tagged_items_property}_tag_cloud=", LazyPage.new( page ) )
      end

    end

    class LazyPage
      def initialize(page)
        @page = page
      end
      def to_s
        @page.content
      end
    end

  end
end
