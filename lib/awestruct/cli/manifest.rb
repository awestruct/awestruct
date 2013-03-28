require 'sass/callbacks'
require 'compass/app_integration'
require 'compass/configuration'
require 'compass/logger'
require 'compass/actions'
require 'compass/commands/base'
require 'compass/commands/registry'
require 'compass/commands/create_project'
require 'compass/installers/bare_installer'

module Compass::AppIntegration::StandAlone
end

class Compass::AppIntegration::StandAlone::Installer
  def write_configuration_files(config_file = nil)
    # no!
  end
  def finalize(opts={})
    $LOG.info <<-END.gsub(/^ {6}/, '')

      Now you're awestruct!

      To generate and run your site in development mode, execute:

        awestruct -d

      or, simply:

        rake

      then visit your site at: http://localhost:4242

    END
  end
end

module Awestruct
  module CLI
    class Manifest

      attr_reader :parent
      attr_reader :steps

      def initialize(parent=nil,&block)
        @parent = parent
        @steps = []
        instance_eval &block if block
      end

      def mkdir(path)
        steps << MkDir.new( path )
      end

      def copy_file(path, input_path)
        steps << CopyFile.new( path, input_path )
      end
      
      def touch_file(path)
        steps << TouchFile.new(path)
      end

      def install_compass(framework)
        steps << InstallCompass.new(framework)
      end

      def perform(dir)
        parent.perform(dir) if parent
        steps.each do |step|
          begin
            step.perform( dir )
          rescue => e
            $LOG.error e if $LOG.error?
            $LOG.error e.backtrace.join("\n") if $LOG.error?
          end
        end
      end

      def unperform(dir)
        steps.each do |step|
          begin
            step.unperform( dir )
          rescue => e
            $LOG.error e if $LOG.error?
            $LOG.error e.backtrace.join("\n") if $LOG.error?
          end
        end
      end

      ##
      ##
      ##
      ##

      class MkDir
        def initialize(path)
          @path = path
        end

        def perform(dir)
          p = File.join( dir, @path ) 
          if ( File.exist?( p ) )
            $LOG.error "Exists: #{p}" if $LOG.error?
            return
          end
          if ( ! File.directory?( File.dirname( p ) ) )
            $LOG.error "Does not exist: #{File.dirname(p)}" if $LOG.error?
            return
          end
          $LOG.info "Create directory: #{p}" if $LOG.info?
          FileUtils.mkdir( p )
        end

        def unperform(dir)
          p = File.join( dir, @path ) 
          if ( ! File.exist?( p ) )
            $LOG.error "Does not exist: #{p}" if $LOG.error?
            return
          end
          if ( ! File.directory?( p ) )
            $LOG.error "Not a directory: #{p}" if $LOG.error?
            return
          end
          if ( Dir.entries( p ) != 2 )
            $LOG.error "Not empty: #{p}" if $LOG.error?
            return
          end
          $LOG.info "Remove: #{p}" if $LOG.info?
          FileUtils.rmdir( p )
        end
      end
      
      class TouchFile
        def initialize(path)
          @path = path
        end
        
        def perform(dir)
          FileUtils.touch(File.join(dir, @path))
        end
        
        def unperform(dir)
          #nothing
        end
      end

      class CopyFile
        def initialize(path, input_path)
          @path       = path
          @input_path = input_path
        end

        def perform(dir )
          p = File.join( dir, @path )
          if ( File.exist?( p ) )
            $LOG.error "Exists: #{p}" if $LOG.error?
            return
          end
          if ( ! File.directory?( File.dirname( p ) ) )
            $LOG.error "No directory: #{File.dirname( p )}" if $LOG.error?
            return
          end
          $LOG.info "Create file: #{p}" if $LOG.info?
          File.open( p, 'w' ){|f| f.write( File.read( @input_path ) ) }
        end

        def unperform(dir)
          # nothing
        end

        def notunperform(dir)
          p = File.join( @dir, p )
          if ( ! File.exist?( p ) )
            $LOG.error "Does not exist: #{p}" if $LOG.error?
            return
          end
          $LOG.info "Remove: #{p}" if $LOG.info?
          FileUtils.rm( p )
        end

      end

      class InstallCompass
        def initialize(framework='compass')
          @framework = framework
        end

        def perform(dir)
          Compass.configuration.sass_dir    = 'stylesheets'
          Compass.configuration.css_dir     = '_site/stylesheets'
          Compass.configuration.images_dir  = 'images'

          cmd = Compass::Commands::CreateProject.new( dir, {
                  :framework=>@framework,
                  :project_type=>:stand_alone,
                  :css_dir=>'_site/stylesheets',
                  :sass_dir=>'stylesheets',
                  :images_dir=>'images',
                  :fonts_dir=>'fonts',
                  :javascripts_dir=>'javascripts',
                } )
          cmd.perform
        end

        def unperform(dir)
          # nothing
        end
      end

    end
  end
end
