
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
        e.execute(site)
      end
    end

    def mixin_helpers(context)
      context.extend( Awestruct::ContextHelper )
      @helpers.each do |h|
        context.extend(h)
      end
    end

  end

end
