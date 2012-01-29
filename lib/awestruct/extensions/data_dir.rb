module Awestruct
  module Extensions
    class DataDir

      def initialize(data_dir="_data")
        @data_dir = data_dir
      end

      def watch(watched_dirs)
          watched_dirs << @data_dir
      end

      def execute(site)
        Dir[ "#{site.dir}/#{@data_dir}/*" ].each do |entry|
          if ( File.directory?( entry ) )
            data_key = File.basename( entry )
            data_map = {}
            Dir[ "#{entry}/*" ].each do |chunk|
              File.basename( chunk ) =~ /^([^\.]+)/
              key = $1.to_sym
              chunk_page = site.engine.load_page( chunk )
              data_map[ key ] = chunk_page
            end
            site.send( "#{data_key}=", data_map )
          end
        end
      end

    end
  end
end
