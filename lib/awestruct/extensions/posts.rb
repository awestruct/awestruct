
module Awestruct
  module Extensions
    class Posts

      def initialize(path_prefix)
        @path_prefix = path_prefix
      end

      def execute(site)
        posts = []
    
        site.pages.each do |page|
          if ( page.relative_source_path =~ /^#{@path_prefix}\/(20[01][0-9])-([01][0-9])-([0123][0-9])-(.*)\.html.haml$/ )
            puts "is a post!"
            year  = $1
            month = $2
            day   = $3
            slug  = $4
            page.date = Time.utc( year.to_i, month.to_i, day.to_i )
            page.slug = slug
            context = OpenStruct.new({
              :site=>site,
              :page=>page,
            })
            #page.body = page.render( context )
            page.output_path = "#{@path_prefix}/#{year}/#{month}/#{day}/#{slug}.html"
            posts << page
          end
        end
        
        posts = posts.sort_by{|each| [each.date, File.mtime( each.source_path ), each.slug ] }.reverse
        
        last = nil
        posts.each do |e|
          if ( last != nil )
             e.next = last
             last.previous = e
          end
          last = e
        end
        
        site.posts = posts
      end
    end
  end
end
