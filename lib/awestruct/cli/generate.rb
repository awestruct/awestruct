require 'awestruct/engine'

module Awestruct
  module CLI
    class Generate

      def initialize(config, profile=nil, base_url=nil, default_base_url='http://localhost:4242', force=false)
        @profile          = profile
        @base_url         = base_url
        @default_base_url = default_base_url
        @force            = force
        @engine           = Awestruct::Engine.new( config )
      end

      def run()
        begin
          base_url = @profile['base_url'] || @default_base_url
          $LOG.info "Generating site: #{base_url}" if $LOG.info?
          @engine.run( @profile, @base_url, ( @profile ? @profile['base_url'] || @default_base_url : @default_base_url ), @force )
        rescue =>e
          $stderr.puts e
          $stderr.puts e.backtrace
          return false
        end
      end
    end
  end
end
