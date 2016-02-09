require 'awestruct/engine'
require 'awestruct/util/exception_helper'

module Awestruct
  module CLI
    class Generate

      def initialize(config, profile=nil, base_url=nil, default_base_url=Options::DEFAULT_BASE_URL, force=false, generate=true)
        @profile          = profile
        @base_url         = base_url
        @default_base_url = default_base_url
        @force            = force
        @generate         = generate
        @engine           = Awestruct::Engine.new( config )
      end

      def run()
        begin
          base_url = @base_url || @default_base_url
          $LOG.info "Generating site: #{base_url}" if $LOG.info?
          start_time = DateTime.now
          @engine.run( @profile, @base_url, @default_base_url, @force, @generate )
          $LOG.trace "Total time in engine.run #{DateTime.now.to_time - start_time.to_time} seconds"
        rescue =>e
          ExceptionHelper.log_building_error e, ''
          return false
        end
      end
    end
  end
end
