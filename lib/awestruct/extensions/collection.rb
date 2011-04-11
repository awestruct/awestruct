
module Awestruct
  module Extensions
    class Collection

      def initialize(assign_to, path_prefix = nil, default_layout = nil)
        @assign_to      = assign_to
        @path_prefix    = path_prefix || '_' + assign_to.to_s
        @default_layout = default_layout || assign_to.to_s.singularize
      end

      def execute(site)
        posts = []

        Dir[ "#{site.dir}/#{@path_prefix}/*" ].each do |entry|
          if entry =~ /^#{site.dir}\/#{@path_prefix}\/(20[01][0-9])-([01][0-9])-([0123][0-9])-([^.]+)\..*$/
            if ( File.directory?( entry ) )
              # TODO deal with dirs
            else
              page = site.engine.load_page( entry )
              year  = $1
              month = $2
              day   = $3
              slug  = $4
              page.date = Time.utc( year.to_i, month.to_i, day.to_i )
              page.slug = slug
              page.output_path = "/#{year}/#{month}/#{day}/#{slug}/index.html"
              page.layout ||= @default_layout

              posts << page
              site.pages << page
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
        end

        site.send( "#{@assign_to}=", posts )
      end
    end
  end
end
