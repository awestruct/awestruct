require 'optparse'

require 'awestruct/version'

module Awestruct
  module CLI

    class Options
      DEFAULT_BIND_ADDR = 'localhost'
      DEFAULT_PORT = 4242
      DEFAULT_BASE_URL = %(http://#{DEFAULT_BIND_ADDR}:#{DEFAULT_PORT})
      DEFAULT_GENERATE_ON_ACCESS = false

      attr_accessor :generate
      attr_accessor :server
      attr_accessor :port
      attr_accessor :bind_addr
      attr_accessor :auto
      attr_accessor :force
      attr_accessor :init
      attr_accessor :framework
      attr_accessor :scaffold
      attr_accessor :base_url
      attr_accessor :profile
      attr_accessor :deploy
      attr_accessor :script
      attr_accessor :verbose
      attr_accessor :quiet
      attr_accessor :source_dir
      attr_accessor :output_dir
      attr_accessor :livereload
      attr_accessor :debug
      attr_accessor :generate_on_access
      attr_accessor :perf_log

      def initialize(opts = {})
        default_opts = { server: false, port: DEFAULT_PORT, bind_addr: DEFAULT_BIND_ADDR, auto: false, force: false,
                         init: false, framework: 'compass', scaffold: true, base_url: DEFAULT_BASE_URL, deploy: false,
                         verbose: false, quiet: false, livereload: false, source_dir: Dir.pwd, debug: false,
                         output_dir: File.expand_path('_site'), generate_on_access: DEFAULT_GENERATE_ON_ACCESS,
                         perf_log: false
                       }.merge opts
        @generate   = default_opts[:generate]
        @server     = default_opts[:server]
        @port       = default_opts[:port]
        @bind_addr  = default_opts[:bind_addr]
        @auto       = default_opts[:auto]
        @force      = default_opts[:force]
        @init       = default_opts[:init]
        @framework  = default_opts[:framework]
        @scaffold   = default_opts[:scaffold]
        @base_url   = default_opts[:base_url]
        @profile    = default_opts[:profile]
        @deploy     = default_opts[:deploy]
        @script     = default_opts[:script]
        @verbose    = default_opts[:verbose]
        @quiet      = default_opts[:quiet]
        @livereload = default_opts[:livereload]
        @source_dir = default_opts[:source_dir]
        @output_dir = default_opts[:output_dir]
        @generate_on_access = default_opts[:generate_on_access]
        @perf_log = default_opts[:perf_log]
        @debug = default_opts[:debug]
      end

      def self.parse!(args)
        Options.new({output_dir: nil}).parse! args
      end

      def parse!(args)
        opts = OptionParser.new do |opts|
          opts.on('-D', '--debug', 'Enable debug logging') do |verbose|
            self.debug = true
          end
          opts.on('-w', '--verbose', 'Enable verbose mode') do |verbose|
            self.verbose = true
          end
          opts.on('-q', '--quiet', 'Only display warnings and errors') do |quiet|
            self.quiet = true
          end
          opts.on( '-i', '--init', 'Initialize a new project in the current directory' ) do |init|
            self.init     = init
            self.generate = false
          end
          opts.on( '-f', '--framework FRAMEWORK', 'Specify a compass framework during initialization (bootstrap, foundation)' ) do |framework|
            self.framework = framework
          end
          opts.on( '--[no-]scaffold', 'Create scaffolding during initialization (default: true)' ) do |s|
            self.scaffold = s
          end
          opts.on( '--force', 'Force a regeneration' ) do |force|
            self.force = force
          end
          opts.on( '-s', '--server', 'Serve generated site' ) do |s|
            self.server = s
          end
          opts.on( '-u', '--url URL', 'Set site.base_url' ) do |url|
            self.base_url = url
          end
          opts.on( '-d', '--dev',     "Run site in development mode (--auto, --server, --port #{DEFAULT_PORT}, --profile development, --livereload and --generate_on_access)" ) do |url|
            self.server   = true
            self.auto     = true
            self.port     = DEFAULT_PORT
            self.profile  = 'development'
            self.livereload = true
            self.generate_on_access = true
          end
          opts.on( '-a', '--auto', 'Auto-generate when changes are noticed' ) do |a|
            self.auto = a
            self.livereload = true
          end
          opts.on( '--[no-]livereload', 'Support for browser livereload' ) do |livereload|
            self.livereload = livereload
            self.generate_on_access = true  if self.livereload
          end

          opts.on( '--[no-]generate-on-access', 'Support for calling generate on HTTP access' ) do |generate_on_access|
            self.generate_on_access = generate_on_access
          end

          opts.on( '-P', '--profile PROFILE', 'Activate a configuration profile' ) do |profile|
            self.profile = profile
          end

          opts.on( '--deploy', 'Deploy site' ) do |deploy|
            self.deploy = deploy
            self.generate = false if self.generate.nil?
          end

          opts.on( '-p', '--port PORT', Integer, "Server port (default: #{DEFAULT_PORT})" ) do |port|
            self.port = port
          end
          opts.on( '-b', '--bind ADDR', "Server address (default: #{DEFAULT_BIND_ADDR})" ) do |bind_addr|
            self.bind_addr = bind_addr
          end
          opts.on( '-g', '--[no-]generate', 'Generate site' ) do |g|
            self.generate = g
          end
          #opts.on( '--run SCRIPT', 'Invoke a script after initialization' ) do |script|
          #  self.script = script
          #end
          opts.on( '--source-dir DIR', 'Location of sources (default: .)' ) do |source_dir|
            self.source_dir = File.expand_path source_dir
          end

          opts.on( '--output-dir DIR', 'Location to output generated site (default: _site)' ) do |output_dir|
            self.output_dir = File.expand_path output_dir
          end

          opts.on('--perf', 'Enable performance logging to .awestruct/perf.log') do
            self.perf_log = true
          end

          opts.separator ''
          opts.separator "Common options:"

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("-v", "--version", "Display the version") do
            puts "Awestruct: #{Awestruct::VERSION}"
            puts "https://awestruct.github.io/"
            exit
          end
        end

        opts.parse!(args)
        self.port ||= DEFAULT_PORT
        self.base_url = %(http://#{self.bind_addr}:#{self.port}) if self.base_url === DEFAULT_BASE_URL
        self.output_dir ||= File.expand_path(File.join(self.source_dir, '_site'))

        self.generate = true if self.generate.nil?
        self
      end # parse()

    end
  end
end
