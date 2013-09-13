require 'awestruct/engine'
require 'compass'

module Awestruct
  module CLI
    class Generate

      def initialize(config, profile=nil, base_url=nil, default_base_url=Options::DEFAULT_BASE_URL, force=false)
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
          $LOG.error e if $LOG.error?
          $LOG.error e.backtrace.join("\n") if $LOG.error?
          return false
        end
      end
    end
  end
end
