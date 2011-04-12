require 'awestruct/engine'

module Awestruct
  module Commands
    class Generate

      def initialize(config, profile=nil, base_url=nil, default_base_url='http://localhost:4242', force=false)
        @dir              = config.input_dir
        @profile          = profile
        @base_url         = base_url
        @default_base_url = default_base_url
        @force            = force
        @engine           = Awestruct::Engine.new( config )
      end

      def run()
        begin
          @engine.generate( @profile, @base_url, @default_base_url, @force )
        rescue =>e
          puts e
          puts e.backtrace
        end
      end
    end
  end
end
