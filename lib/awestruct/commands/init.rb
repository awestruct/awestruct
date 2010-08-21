require 'awestruct'
require 'awestruct/commands/manifest'

module Awestruct
  module Commands
    class Init

      BASE_MANIFEST = Manifest.new {
        mkdir( '_config' )
        mkdir( '_layouts' )
        mkdir( '_ext' )
        copy_file( '_ext/pipeline.rb', File.join( File.dirname(__FILE__), 'frameworks/base_pipeline.rb' ) )
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
        scaffold_name = ( @framework == 'compass' ? 'blueprint' : @framework )
        if ( @scaffold )
          manifest.copy_file( '_layouts/base.html.haml', File.join( File.dirname(__FILE__), "/frameworks/#{scaffold_name}/base_layout.html.haml" ) )
          manifest.copy_file( 'index.html.haml', File.join( File.dirname(__FILE__), "/frameworks/base_index.html.haml" ) )
          manifest.touch_file( '_config/site.yml' )
        end
        manifest.perform( @dir )
      end

    end
  end
end
