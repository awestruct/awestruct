require 'awestruct/handler_chains'
require 'awestruct/context_helper'

module Awestruct

  class Pipeline

    attr_reader :handler_chains

    def initialize()
      @handler_chains = HandlerChains.new
      @extensions     = []
      @helpers        = []
      @transformers   = []
    end

    def extension(e)
      @extensions << e
      # TC: why? transformer and extension?
      e.transform(@transformers) if e.respond_to?('transform')
    end

    def helper(h)
      @helpers << h
    end

    def transformer(t)
      @transformers << t
    end

    def execute(site)
      execute_extensions(site)
    end

    def execute_extensions(site)
      @extensions.each do |e|
        start_time = DateTime.now
        e.execute(site)
        puts "Time in #{e} extension: #{DateTime.now.to_time - start_time.to_time} seconds"
      end
    end

    def apply_transformers(site, page, rendered)
      @transformers.each do |t|
        rendered = t.transform( site, page, rendered )
      end
      rendered
    end

    def mixin_helpers(context)
      context.extend( Awestruct::ContextHelper )
      @helpers.each do |h|
        context.extend(h)
      end
    end

  end

end
