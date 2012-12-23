module Awestruct
  module Extensions
    class Posts

      attr_accessor :path_prefix, :assign_to, :archive_template, :archive_path

      def initialize(path_prefix='', assign_to=:posts, archive_template=nil, archive_path=nil)
        @archive_template = archive_template
        @archive_path     = archive_path
        @path_prefix      = path_prefix
        @assign_to        = assign_to
        @handle_subdirs    = true
      end

      def execute(site)
        posts   = []
        archive = Archive.new

        site.pages.each do |page|
          year, month, day, slug = nil

          if ( page.relative_source_path =~ /^#{@path_prefix}\// )
            if (@handle_subdirs)
              regexp_date = /^#{@path_prefix}(\/.*)*\/(20[01][0-9])-([01][0-9])-([0123][0-9])-([^.]+)\..*$/
              regexp_general = /^#{@path_prefix}(\/.*)*\/(.*)\..*$/
              offset = 1
            else
              regexp_date = /^#{@path_prefix}\/(20[01][0-9])-([01][0-9])-([0123][0-9])-([^.]+)\..*$/
              regexp_general = /^#{@path_prefix}\/(.*)\..*$/
              offset = 0
            end
            # check for a date inside the page first
            if (page.date?)
              page.relative_source_path =~ regexp_general
              date = page.date;
              if date.kind_of? String
                date = Time.parse page.date
              end
              year = date.year
              month = sprintf( "%02d", date.month )
              day = sprintf( "%02d", date.day )
              page.date = date
              slug = $~[1 + offset]
              if ( page.relative_source_path =~ regexp_date )
                slug = $~[4 + offset]
              end
            elsif ( page.relative_source_path =~ regexp_date )
              year  = $~[1 + offset]
              month = $~[2 + offset]
              day   = $~[3 + offset]
              slug  = $~[4 + offset]
              page.date = Time.utc( year.to_i, month.to_i, day.to_i )
            end

            # if a date was found create a post
            if( year and month and day)
              page.slug ||= slug
              context = page.create_context
              page.output_path = "#{@path_prefix}/#{year}/#{month}/#{day}/#{page.slug}.html"
              posts << page
            end
          end
        end

        posts = posts.sort_by{|each| [each.date, each.sequence || 0, File.mtime( each.source_path ), each.slug ] }.reverse

        last = nil
        singular = @assign_to.to_s.singularize
        posts.each do |e|
          if ( last != nil )
             e.send( "next_#{singular}=", last )
             last.send( "previous_#{singular}=", e )
          end
          last = e
          archive << e
        end
        site.pages.concat( archive.generate_pages( site.engine, archive_template, archive_path ) ) if (archive_template && archive_path)
        site.send( "#{@assign_to}=", posts )
        site.send( "#{@assign_to}_archive=", archive )

      end


      class Archive
        attr_accessor :posts

        def initialize
          @posts        = {}
        end

        def <<( post )
          posts[post.date.year] ||= {}
          posts[post.date.year][post.date.month] ||= {}
          posts[post.date.year][post.date.month][post.date.day] ||= []
          posts[post.date.year][post.date.month][post.date.day] << post
        end

        def generate_pages( engine, template, output_path )
          pages = []
          posts.keys.sort.each do |year|
            posts[year].keys.sort.each do |month| 
              posts[year][month].keys.sort.each do |day|
                archive_page = engine.find_and_load_site_page( template )
                archive_page.send( "archive=", posts[year][month][day] )
                archive_page.output_path = File.join( output_path, year.to_s, month.to_s, day.to_s, File.basename( template ) + ".html" )
                pages << archive_page
              end
            end
          end
          pages
        end
      end

    end
  end
end

