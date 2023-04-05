require 'pathname'
require 'logging'
require 'awestruct/cli/options'
require 'awestruct/util/exception_helper'
require 'erb'

module Awestruct
  module CLI
    class Invoker

      attr_reader :options

      attr_reader :config
      attr_reader :profile
      attr_reader :success

      def initialize(*options)
        options = options.flatten
        if (!options.empty?) && (options.first === Awestruct::CLI::Options)
          @options = options.first
        else
          @options = Awestruct::CLI::Options.parse! options
        end
        @threads = []
        @profile = nil
        @success = true
        logging_path = Pathname.new File.join(@options.source_dir, '.awestruct')
        logging_path.mkpath unless logging_path.exist?

        Logging.init :trace, :debug, :verbose, :info, :warn, :error, :fatal
        $LOG = Logging.logger.new 'awestruct'
        $LOG.add_appenders(
                Logging.appenders.stdout({level: (@options.verbose ? :verbose : :info),
                                          layout: Logging.layouts.pattern(pattern: "%m\n", format_as: :string),
                                          color_scheme: :default}),
                Logging.appenders.file('error', {filename: File.join(logging_path, 'error.log'),
                                                 layout: Logging.layouts.parseable.json(format_as: :string),
                                                 truncate: true, level: :error})
        )

        if @options.debug
          $LOG.add_appenders(
              Logging.appenders.file('debug', {filename: File.join(logging_path, 'debug.log'),
                                               layout: Logging.layouts.parseable.json(format_as: :string),
                                               truncate: true, level: :debug})
          )
        end

        if @options.perf_log
          $LOG.add_appenders(
              Logging.appenders.file('perf', {filename: File.join(logging_path, 'perf.log'),
                                              truncate: true, level: :trace,
                                              layout: Logging.layouts.parseable.json(format_as: :string),
                                              filters: Logging::Filters::Level.new(:trace)})
          )
        end

        # these requires are deferred until after $LOG is set
        require 'awestruct/cli/init'
        require 'awestruct/cli/generate'
        require 'awestruct/cli/auto'
        require 'awestruct/cli/server'
      end

      def invoke!
        begin
          load_profile() unless ( options.init )

          setup_config()

          invoke_init()      if ( options.init )
          invoke_script()    if ( options.script )
          invoke_force()     if ( options.force )
          invoke_generate()  if ( options.generate )
          invoke_deploy()    if ( options.deploy )
          invoke_server()    if ( options.server )
          invoke_auto()      if ( options.auto )

          wait_for_completion()

          if ExceptionHelper.build_failed? || @success == false
            @success = false
            false
          else
            true
          end
        rescue => e
          $LOG.fatal "Caught exception; exiting"
          $LOG.fatal e
          @success = false
          false
        end
      end

      def load_profile()
        site_yaml_file = File.join( @options.source_dir, '_config', 'site.yml' )

        if ( !File.exist?( site_yaml_file ) )
          abort( "No config file at #{site_yaml_file}" )
        end

        site_yaml = YAML.load( ERB.new(File.read( site_yaml_file ), trim_mode: '<>').result )

        if ( !site_yaml )
          abort( "Failed to parse #{site_yaml_file}" )
        end

        profiles = site_yaml['profiles'] || {}

        profile_name = options.profile

        # use the one specified
        profile = profiles[profile_name]
        if ( !profile )
          profile_name, profile = if ( options.deploy )
            # or the first one having a deploy section
            profiles.select { |k,v| v && v['deploy'] }
          else
            # or the first one having no deploy section
            profiles.select { |k,v| v && !v['deploy'] }
          end.first
        end

        if profile
          $LOG.info "Using profile: #{profile_name}" if $LOG.info?
        end

        @profile = profile || {}
      end

      def setup_config()
        @config = Awestruct::Config.new( @options )
        @config.track_dependencies = true if ( @options.auto )
        @config.verbose = true if ( @options.verbose )
        @config.debug = @options.debug
        @config.quiet = true if @options.quiet
        @config.perf = true if @options.perf_log
      end

      def invoke_init()
        Awestruct::CLI::Init.new( @options.source_dir, @options.framework, @options.scaffold ).run
      end

      def invoke_script()
      end

      def invoke_force()
        FileUtils.rm_rf( File.join( config.dir, '.awestruct', 'dependency-cache' ) )
        FileUtils.rm_rf( config.output_dir )
      end

      def invoke_generate()
        base_url = profile['base_url'] || options.base_url
        @success = Awestruct::CLI::Generate.new( config, options.profile, base_url, Options::DEFAULT_BASE_URL, options.force, !options.generate_on_access ).run
      end

      def invoke_deploy()
        require 'awestruct/cli/deploy'

        deploy_config = profile[ 'deploy' ]

        if ( deploy_config.nil? )
          $LOG.error "No configuration for 'deploy'" if $LOG.error?
          return
        end

        Awestruct::CLI::Deploy.new( config, deploy_config ).run
      end

      def invoke_auto()
        base_url = profile['base_url'] || options.base_url
        Awestruct::CLI::Auto.new( config, base_url ).run
      end

      def invoke_server()
        run_in_thread( Awestruct::CLI::Server.new( options.output_dir, options.bind_addr, options.port, options.generate_on_access ) )
      end


      private

      def run_in_thread(command)
        @threads << Thread.new(command){|c| c.run}
      end

      def wait_for_completion()
        @threads.each do |thr|
          thr.join
        end
      end

    end
  end
end
