require 'compass/logger'
require 'compass/actions'
require 'compass/commands/base'
require 'compass/commands/create_project'
require 'compass/installers/stand_alone'

class Compass::Installers::StandAloneInstaller
  def write_configuration_files(config_file=nil)
    # skip it!
  end

  def compilation_required?
    false
  end
end

module Awestruct
  module Commands
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

      def install_compass(framework)
        steps << InstallCompass.new(framework)
      end

      def perform(dir)
        parent.perform(dir) if parent
        steps.each do |step|
          begin
            step.perform( dir )
          rescue => e
            puts e
            puts e.backtrace
          end
        end
      end

      def unperform(dir)
        steps.each do |step|
          begin
            step.unperform( dir )
          rescue => e
            puts e
            puts e.backtrace
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
            $stderr.puts "Exists: #{p}"
            return
          end
          if ( ! File.directory?( File.dirname( p ) ) )
            $stderr.puts "Does not exist: #{File.dirname(p)}"
            return
          end
          $stderr.puts "Create directory: #{p}"
          FileUtils.mkdir( p )
        end

        def unperform(dir)
          p = File.join( dir, @path ) 
          if ( ! File.exist?( p ) )
            $stderr.puts "Does not exist: #{p}"
            return
          end
          if ( ! File.directory?( p ) )
            $stderr.puts "Not a directory: #{p}"
            return
          end
          if ( Dir.entries( p ) != 2 )
            $stderr.puts "Not empty: #{p}"
            return
          end
          $stderr.puts "Remove: #{p}"
          FileUtils.rmdir( p )
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
            $stderr.puts "Exists: #{p}"
            return
          end
          if ( ! File.directory?( File.dirname( p ) ) )
            $stderr.puts "No directory: #{File.dirname( p )}"
            return
          end
          $stderr.puts "Create file: #{p}"
          File.open( p, 'w' ){|f| f.write( File.read( @input_path ) ) }
        end

        def unperform(dir)
          # nothing
        end

        def notunperform(dir)
          p = File.join( @dir, p )
          if ( ! File.exist?( p ) )
            $stderr.puts "Does not exist: #{p}"
            return
          end
          $stderr.puts "Remove: #{p}"
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
                  #:css_dir=>'_site/stylesheets',
                  #:sass_dir=>'stylesheets',
                  :images_dir=>'images',
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
