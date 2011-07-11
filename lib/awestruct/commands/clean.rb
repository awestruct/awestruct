require 'awestruct'
require 'awestruct/commands/manifest'

module Awestruct
  module Commands
    class Clean

      def initialize( site_path )
        @site_path = site_path
      end

      def run
        puts "removing '#{@site_path}'"
        FileUtils.remove_dir(@site_path, force = true)
      end

    end
  end
end
