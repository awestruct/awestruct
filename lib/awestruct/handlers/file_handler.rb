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
        @relative_source_path = nil
      end

      def output_filename
        File.basename( @path )
      end

      def relative_source_path
        return @relative_source_path unless @relative_source_path.nil?
        begin
          @relative_source_path = "/#{Pathname.new path.relative_path_from( site.dir )}"
        rescue Exception=>e
          nil
        end
        @relative_source_path
      end

      def stale?
        return true if ( @content.nil? || ( File.mtime( @path ) > @mtime ) )
        false
      end

      def input_mtime(page)
        path.mtime
      end

      def raw_content
        load_content
      end

      def rendered_content(context, with_layouts=true)
        raw_content
      end
      
      def read_content
        File.open(@path, 'r') {|is| is.read }
      end

      private 

      def load_content
        ( @content = read_content ) if stale?
        @mtime = File.mtime( @path )
        @content
      end

    end
  end
end
