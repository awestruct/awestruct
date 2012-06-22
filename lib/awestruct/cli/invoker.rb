require 'awestruct/cli/options'

require 'awestruct/cli/init'
require 'awestruct/cli/generate'
require 'awestruct/cli/auto'
require 'awestruct/cli/server'
require 'awestruct/cli/deploy'

require 'pathname'

module Awestruct
  module CLI
    class Invoker

      attr_reader :options

      attr_reader :config
      attr_reader :profile
      attr_reader :success

      def initialize(*options)
        options = options.flatten
        if ( ( ! options.empty? ) && ( options.first === Awestruct::CLI::Options ) )
          @options = options.first
        else
          @options = Awestruct::CLI::Options.parse! options
        end
        @threads = []
        @profile = nil
        @success = true
      end

      def invoke!
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
        success
      end

      def load_profile()
        site_yaml_file = File.join( Dir.pwd, '_config', 'site.yml' )
        if ( File.exist?( site_yaml_file ) )
          site_yaml      = YAML.load( File.read( site_yaml_file ) )
          if site_yaml
            profiles_data  = site_yaml['profiles'] || {}
            @profile = if profiles_data.nil?
              nil
            else
              if options.profile
                profiles_data[options.profile] || {}
              else
                # if no profile given, pick the first with deploy config
                options.profile, profile_data = profiles_data.select { |k,v| v && v['deploy'] }.first
                profile_data
              end
            end
          end
        end
 
        unless @profile
          $stderr.puts "Unable to locate profile: #{options.profile}" if options.profile
          options.profile = 'NONE'
          @profile = {}
        end 
        $stderr.puts "Using profile: #{options.profile}"
      end

      def setup_config()
        @config = Awestruct::Config.new( Dir.pwd )
        @config.track_dependencies = true if ( options.auto )
      end

      def invoke_init()
        Awestruct::CLI::Init.new( Dir.pwd, options.framework, options.scaffold ).run
      end

      def invoke_script()
      end

      def invoke_force()
        FileUtils.rm_rf( File.join( config.dir, '.awestruct', 'dependency-cache' ) )
        FileUtils.rm_rf( config.output_dir )
      end

      def invoke_generate()
        @success = Awestruct::CLI::Generate.new( config, options.profile, options.base_url, 'http://localhost:4242', options.force ).run
      end

      def invoke_deploy()
        deploy_config = profile[ 'deploy' ]

        if ( deploy_config.nil? )
          $stderr.puts "No configuration for 'deploy'"
          return
        end

        Awestruct::CLI::Deploy.new( config, deploy_config ).run
      end

      def invoke_auto()
        Awestruct::CLI::Auto.new( config ).run
      end

      def invoke_server()
        run_in_thread( Awestruct::CLI::Server.new( './_site', options.bind_addr, options.port ) )
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
