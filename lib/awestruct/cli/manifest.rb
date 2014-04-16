require 'sass/callbacks'
require 'compass/app_integration'
require 'compass/configuration'
require 'compass/logger'
require 'compass/actions'
require 'compass/commands/base'
require 'compass/commands/registry'
require 'compass/commands/create_project'
require 'compass/installers/bare_installer'

module ::Compass::AppIntegration::StandAlone
end

class ::Compass::AppIntegration::StandAlone::Installer
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

      then visit your site at: #{::Awestruct::CLI::Options::DEFAULT_BASE_URL}
    END
  end
end

module Awestruct
  module CLI
    #noinspection RubyResolve
    class Manifest

      attr_reader :parent
      attr_reader :steps

      def initialize(parent=nil, &block)
        @parent = parent
        @steps = []
        instance_eval &block if block
      end

      def mkdir(path)
        steps << MkDir.new(path)
      end

      def copy_file(path, input_path, opts = {})
        steps << CopyFile.new(path, input_path, opts)
      end

      def touch_file(path)
        steps << TouchFile.new(path)
      end

      def remove_file(path)
        steps << RemoveFile.new(path)
      end

      def add_requires(path, libs = [])
        steps << AddRequires.new(path, libs)
      end

      def install_compass(framework)
        steps << InstallCompass.new(framework)
      end

      def perform(dir)
        parent.perform(dir) if parent
        begin
          steps.each do |step|
            step.perform(dir)
          end
          true
        rescue => e
          ExceptionHelper.log_error e
          ExceptionHelper.log_backtrace e
          false
        end
      end

      def unperform(dir)
        steps.each do |step|
          begin
            step.unperform(dir)
            true
          rescue => e
            ExceptionHelper.log_error e
            ExceptionHelper.log_backtrace e
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
          p = File.join(dir, @path)
          if File.exist?(p)
            $LOG.error "Exists: #{p}" if $LOG.error?
            return
          end
          unless File.directory?(File.dirname(p))
            $LOG.error "Does not exist: #{File.dirname(p)}" if $LOG.error?
            return
          end
          $LOG.info "Create directory: #{p}" if $LOG.info?
          FileUtils.mkdir(p)
        end

        def unperform(dir)
          p = File.join(dir, @path)
          unless File.exist?(p)
            $LOG.error "Does not exist: #{p}" if $LOG.error?
            return
          end
          unless File.directory?(p)
            $LOG.error "Not a directory: #{p}" if $LOG.error?
            return
          end
          if Dir.entries(p) != 2
            $LOG.error "Not empty: #{p}" if $LOG.error?
            return
          end
          $LOG.info "Remove: #{p}" if $LOG.info?
          FileUtils.rmdir(p)
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

      class RemoveFile
        def initialize(path)
          @path = path
        end

        def perform(dir)
          FileUtils.rm(File.join(dir, @path), :force => true)
        end

        def unperform(dir)
          #nothing
        end
      end

      # Adds a requires for each library in libs to the
      # top of the file specified by path
      class AddRequires
        def initialize(path, libs)
          @path = path
          @libs = libs
        end

        def perform(dir)
          file = File.join(dir, @path)
          old_lines = File.read file
          FileUtils.rm(file)

          File.open(file, 'w') do |new|
            @libs.each do |lib|
              new.write "require '#{lib}'\n"
            end
            new.write old_lines
          end
        end

        def unperform(dir)
          #nothing
        end
      end

      class CopyFile
        def initialize(path, input_path, opts = {})
          @path = path
          @input_path = input_path
          @overwrite = opts[:overwrite]
        end

        def perform(dir)
          p = File.join(dir, @path)
          if !@overwrite && File.exist?(p)
            $LOG.error "Exists: #{p}" if $LOG.error?
            return
          end
          unless File.directory?(File.dirname(p))
            $LOG.error "No directory: #{File.dirname(p)}" if $LOG.error?
            return
          end
          $LOG.info "Create file: #{p}" if $LOG.info?
          File.open(p, 'w') { |f| f.write(File.read(@input_path)) }
        end

        def unperform(dir)
          # nothing
        end

        def notunperform(dir)
          p = File.join(@dir, p)
          unless File.exist?(p)
            $LOG.error "Does not exist: #{p}" if $LOG.error?
            return
          end
          $LOG.info "Remove: #{p}" if $LOG.info?
          FileUtils.rm(p)
        end

      end

      class InstallCompass
        def initialize(framework='compass')
          @framework = framework
        end

        def perform(dir)
          ::Compass.configuration.sass_dir = 'stylesheets'
          ::Compass.configuration.css_dir = '_site/stylesheets'
          ::Compass.configuration.images_dir = 'images'

          cmd = ::Compass::Commands::CreateProject.new(dir, {
              :framework => @framework,
              :project_type => :stand_alone,
              :css_dir => '_site/stylesheets',
              :sass_dir => 'stylesheets',
              :images_dir => 'images',
              :fonts_dir => 'fonts',
              :javascripts_dir => 'javascripts',
          })
          cmd.perform
        end

        def unperform(dir)
          # nothing
        end
      end

    end
  end
end
