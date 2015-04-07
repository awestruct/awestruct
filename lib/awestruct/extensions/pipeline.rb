
Dir[ File.join( File.dirname(__FILE__), '*.rb' ) ].each do |f|
  begin
    require f
  rescue LoadError => e
    $LOG.warn "Missing required dependency to activate optional built-in extension #{File.basename(f)}\n  #{e}" if $LOG.debug?
  rescue StandardError => e
    $LOG.warn "Missing runtime configuration to activate optional built-in extension #{File.basename(f)}\n  #{e}" if $LOG.debug?
  end
end

module Awestruct
  module Extensions
    # Public. Extension declaration class, initialized by the end user to
    # declare their extensions, helpers, transformers, etc.
    class Pipeline

      attr_reader :before_pipeline_extensions
      attr_reader :extensions
      attr_reader :after_pipeline_extensions
      attr_reader :helpers
      attr_reader :transformers
      attr_reader :after_generation_extensions

      def initialize(&block)
        @before_pipeline_extensions  = []
        @extensions                  = []
        @helpers                     = []
        @transformers                = []
        @after_pipeline_extensions   = []
        @after_generation_extensions = []
        begin
          instance_eval(&block) if block
        rescue Exception => e
          abort("Failed to initialize pipeline: #{e}")
        end
      end

      def before_extensions(ext)
        @before_pipeline_extensions << ext
      end

      def extension(ext)
        @extensions << ext
        # TC: why? transformer and extension?
        ext.transform(@transformers) if ext.respond_to?('transform')
      end

      def after_extensions(ext)
        @after_pipeline_extensions << ext
      end

      def helper(helper)
        @helpers << helper
      end

      def transformer(transformer)
        @transformers << transformer
      end

      def after_generation(ext)
        @after_generation_extensions << ext
      end

      def execute(site)
        extensions.each do |ext|
          ext.execute( site )
        end
      end

      def watch(watched_dirs)
        extensions.each do |ext|
          ext.watch( watched_dirs ) if ext.respond_to?('watch')
        end
      end

      private
      def site
        Awestruct::Engine.instance.site
      end

    end
  end
end
