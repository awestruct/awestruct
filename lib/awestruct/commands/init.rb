require 'awestruct'
require 'awestruct/commands/manifest'


module Awestruct
  module Commands
    class Init

      BASE_MANIFEST = Manifest.new {
        mkdir( '_config' )
        mkdir( '_layouts' )
        mkdir( 'stylesheets' )
      }

      def initialize(dir=Dir.pwd,framework=nil)
        @dir       = dir
        @framework = framework
      end

      def run()
        manifest = Manifest.new( BASE_MANIFEST )
        manifest.install_compass( @framework )
        manifest.perform( @dir )
      end

    end
  end
end
