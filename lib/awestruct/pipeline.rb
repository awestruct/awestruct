require 'awestruct/handler_chains'
require 'awestruct/context_helper'

module Awestruct

  class Pipeline

    attr_reader :handler_chains
    attr_reader :before_pipeline_extensions
    attr_reader :extensions
    attr_reader :after_pipeline_extensions
    attr_reader :helpers
    attr_reader :transformers
    attr_reader :after_generation_extensions

    def initialize()
      @handler_chains = HandlerChains.new
      @before_pipeline_extensions  = []
      @extensions                  = []
      @helpers                     = []
      @transformers                = []
      @after_pipeline_extensions   = []
      @after_generation_extensions = []
    end

    def before_pipeline_extension(e)
      @before_pipeline_extensions << e
    end

    def extension(e)
      @extensions << e
      # TC: why? transformer and extension?
      e.transform(@transformers) if e.respond_to?('transform')
    end

    def after_pipeline_extension(e)
      @after_pipeline_extensions << e
    end

    def helper(h)
      @helpers << h
    end

    def transformer(t)
      @transformers << t
    end

    def after_generation_extension(e)
      @after_generation_extensions << e
    end

    def execute(site, on_reload = false)
      execute_extensions(site, on_reload)
    end

    def execute_extensions(site, on_reload)
      @before_pipeline_extensions.each do |e|
        e.on_reload(site) if (on_reload && e.respond_to?(:on_reload))
        e.execute(site)
      end

      @extensions.each do |e|
        e.on_reload(site) if (on_reload && e.respond_to?(:on_reload))
        e.execute(site)
      end

      @after_pipeline_extensions.each do |e|
        e.on_reload(site) if (on_reload && e.respond_to?(:on_reload))
        e.execute(site)
      end
    end

    def apply_transformers(site, page, rendered)
      @transformers.each do |t|
        rendered = t.transform( site, page, rendered )
      end
      rendered
    end

    def execute_after_generation(site)
      @after_generation_extensions.each do |e|
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
