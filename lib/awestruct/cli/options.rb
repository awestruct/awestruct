require 'optparse'

require 'awestruct/version'

module Awestruct
  module CLI

    class Options

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
      attr_accessor :source_dir
      attr_accessor :output_dir

      def initialize()
        @generate  = nil
        @server    = false
        @port      = 4242
        @bind_addr = '0.0.0.0'
        @auto      = false
        @force     = false
        @init      = false
        @framework = 'compass'
        @scaffold  = true
        @base_url  = nil
        @profile   = nil
        @deploy    = false
        @script    = nil
        @verbose   = false
        @source_dir = Dir.pwd
        @output_dir = File.expand_path '_site'
      end

      def self.parse!(args)
        Options.new.parse! args
      end

      def parse!(args)
        opts = OptionParser.new do |opts|
          opts.on('-w', '--verbose', 'Enable verbose mode') do |verbose|
            self.verbose = true
          end
          opts.on( '-i', '--init', 'Initialize a new project in the current directory' ) do |init|
            self.init     = init
            self.generate = false
          end
          opts.on( '-f', '--framework FRAMEWORK', 'Specify a compass framework during initialization (bootstrap, foundation, blueprint, 960)' ) do |framework|
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
          opts.on( '-d', '--dev',     'Run site in development mode (--auto, --server, --port 4242 and --profile development)' ) do |url|
            self.server   = true
            self.auto     = true
            self.port     = 4242
            self.profile  = 'development'
          end

          opts.on( '-P', '--profile PROFILE', 'Activate a configuration profile' ) do |profile|
            self.profile = profile
          end
      
          opts.on( '--deploy', 'Deploy site' ) do |deploy|
            self.deploy = deploy
            self.generate = false if self.generate.nil?
          end
      
          opts.on( '-a', '--auto', 'Auto-generate when changes are noticed' ) do |a|
            self.auto = a
          end
          opts.on( '-p', '--port PORT', Integer, 'Server port (default: 4242)' ) do |port|
            self.port = port
          end
          opts.on( '-b', '--bind ADDR', 'Server address (default: 0.0.0.0)' ) do |bind_addr|
            self.bind_addr = bind_addr
          end
          opts.on( '-g', '--[no-]generate', 'Generate site' ) do |g|
            self.generate = g
          end
          #opts.on( '--run SCRIPT', 'Invoke a script after initialization' ) do |script|
          #  self.script = script
          #end
          opts.on( '--source-dir DIR', 'Location of sources (default: .' ) do |source_dir|
            self.source_dir = File.expand_path source_dir
          end

          opts.on( '--output-dir DIR', 'Location to output generated site (default: _site' ) do |output_dir|
            self.output_dir = File.expand_path output_dir
          end
      
          opts.separator ''
          opts.separator "Common options:"
      
          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end
  
          opts.on_tail("-v", "--version", "Display the version") do
            puts "Awestruct: #{Awestruct::VERSION}"
            puts "http://awestruct.org/"
            exit
          end
        end

        opts.parse!(args)
        self.generate = true if self.generate.nil?
        self
      end # parse()

    end
  end
end
