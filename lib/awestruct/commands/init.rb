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

      def initialize(dir=Dir.pwd,framework='compass',scaffold=true)
        @dir       = dir
        @framework = framework
        @scaffold  = scaffold
      end

      def run()
        manifest = Manifest.new( BASE_MANIFEST )
        manifest.install_compass( @framework )
        if ( @scaffold )
          manifest.create_file( '_layouts/base.html.haml', File.read( File.dirname(__FILE__) + '/base_layout.html.haml' ) )
          manifest.create_file( 'index.html.haml', File.read( File.dirname(__FILE__) + '/base_index.html.haml' ) )
        end
        manifest.perform( @dir )
      end

    end
  end
end
