require 'awestruct/handlers/base_handler'

module Awestruct
  module Handlers
    class FileHandler < BaseHandler

      attr_accessor :path

      def initialize(site, path)
        super( site )
        case ( path )
          when Pathname
            @path = path
          else
            @path = Pathname.new( path.to_s )
        end
      end

      def output_filename
        File.basename( @path )
      end

      def relative_source_path
        begin
          p = path.relative_path_from( site.dir ) 
          if !! ( %r(^\.\.) =~ p.to_s )
            return nil 
          end
          r = File.join( '', p )
          return r
        rescue Exception=>e
          nil
        end
      end

      def stale?
        return true if ( @content.nil? || ( File.mtime( @path ) > @mtime ) )
        false
      end

      def input_mtime(page)
        path.mtime
      end

      def raw_content
        read
        @content
      end

      def rendered_content(context, with_layouts=true)
        raw_content
      end

      private 

      def read
        ( @content = open ) if stale?
        @mtime = File.mtime( @path )
        return @content
      end
      
      def open
        input_stream = IO.open(IO.sysopen(@path, "rb"), "rb" )
        result = input_stream.read
        input_stream.close
        return result
      end

    end
  end
end
