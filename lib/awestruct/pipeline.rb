require 'awestruct/handler_chains'
require 'awestruct/context_helper'

module Awestruct

  class Pipeline

    attr_reader :handler_chains
    attr_reader :before_all_extensions
    attr_reader :extensions
    attr_reader :after_all_extensions
    attr_reader :helpers
    attr_reader :transformers
    attr_reader :after_generation_extensions

    def initialize
      @handler_chains = HandlerChains.new
      @before_all_extensions       = []
      @extensions                  = []
      @helpers                     = []
      @transformers                = []
      @after_all_extensions        = []
      @after_generation_extensions = []
    end

    def add_before_extension(e)
      @before_all_extensions << e
    end

    def extension(e)
      @extensions << e
    end

    def add_after_extension(e)
      @after_all_extensions << e
    end

    def helper(h)
      @helpers << h
    end

    def transformer(t)
      @transformers << t
    end

    def add_after_generation_extension(e)
      @after_generation_extensions << e
    end

    def execute(site, on_reload = false)
      execute_extensions(site, on_reload)
    end

    def execute_extensions(site, on_reload)
      @before_all_extensions.each do |e|
        $LOG.verbose "Executing before all extension #{e.class}" if site.config.verbose

        if on_reload && e.respond_to?
          start_time = DateTime.now
          e.on_reload(site) if (on_reload && e.respond_to?(:on_reload))
          $LOG.trace "Total time in #{e.class}.on_reload #{DateTime.now.to_time - start_time.to_time} seconds"
        end

        start_time = DateTime.now
        if e.respond_to? :execute
          e.execute(site)
        else
          e.before_extensions(site)
        end
        $LOG.trace "Total time in #{e.class}.before_extensions #{DateTime.now.to_time - start_time.to_time} seconds"
      end

      @extensions.each do |e|
        $LOG.verbose "Executing extension #{e.class}" if site.config.verbose
        if on_reload && e.respond_to?(:on_reload)
          start_time = DateTime.now
          e.on_reload(site)
          $LOG.trace "Total time in #{e.class}.on_reload #{DateTime.now.to_time - start_time.to_time} seconds"
        end
        start_time = DateTime.now
        e.execute(site)
        $LOG.trace "Total time in #{e.class}.execute #{DateTime.now.to_time - start_time.to_time} seconds"
      end

      @after_all_extensions.each do |e|
        $LOG.verbose "Executing after all extension #{e.class}" if site.config.verbose
        if on_reload && e.respond_to?(:on_reload)
          start_time = DateTime.now
          e.on_reload(site)
          $LOG.trace "Total time in #{e.class}.on_reload #{DateTime.now.to_time - start_time.to_time} seconds"
        end

        start_time = DateTime.now
        if e.respond_to? :execute
          e.execute(site)
        else
          e.after_generation(site)
        end
        $LOG.trace "Total time in #{e.class}.after_generation #{DateTime.now.to_time - start_time.to_time} seconds"
      end
    end

    def apply_transformers(site, page, rendered)
      @transformers.each do |t|
        $LOG.debug "Applying transformer #{t.class} for page #{page}" if site.config.verbose && site.config.debug
        start_time = DateTime.now
        rendered = t.transform( site, page, rendered )
        $LOG.trace "Total time in #{t.class}.transform #{DateTime.now.to_time - start_time.to_time} seconds" if site.config.verbose
      end
      rendered
    end

    def execute_after_generation(site)
      @after_generation_extensions.each do |e|
        $LOG.verbose "Executing after generation #{e.class}" if site.config.verbose
        start_time = DateTime.now
        if e.respond_to? :execute
          e.execute(site)
        else
          e.after_generation(site)
        end
        $LOG.trace "Total time in #{e.class}.after_generation #{DateTime.now.to_time - start_time.to_time} seconds"
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
