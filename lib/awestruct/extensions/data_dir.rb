require 'awestruct/util/yaml_load'

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
        Dir.glob(File.join(site.dir, @data_dir, '*')).each do |entry|
          next unless File.directory? entry
          data_key = File.basename(entry)
          data_map = {}
          Dir.glob(File.join(entry, '*')).each do |chunk|
            File.basename(chunk) =~ /^([^\.]+)/
            key = $1.to_sym
            chunk_page = nil
            if chunk.end_with?('.yml')
              chunk_page = Awestruct.yaml_load_file(chunk)
            else
              chunk_page = site.engine.load_page(chunk)
            end
            data_map[key] = chunk_page
          end
          site.send("#{data_key}=", data_map)
        end
      end

    end
  end
end
