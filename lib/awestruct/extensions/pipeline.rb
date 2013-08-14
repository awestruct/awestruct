
Dir[ File.join( File.dirname(__FILE__), '*.rb' ) ].each do |f|
  begin
    require f
  rescue LoadError => e
    puts "WARNING: Missing required dependency to activate optional built-in extension #{File.basename(f)}\n  #{e}" if $LOG.debug?
  rescue StandardError => e
    puts "WARNING: Missing runtime configuration to activate optional built-in extension #{File.basename(f)}\n  #{e}" if $LOG.debug?
  end
end

module Awestruct
  module Extensions
    class Pipeline

      attr_reader :before_extensions
      attr_reader :extensions
      attr_reader :after_extensions
      attr_reader :helpers
      attr_reader :transformers

      def initialize(&block)
        @extensions = []
        @helpers    = []
        @transformers  = []
        instance_eval &block if block
      end

      def extension(ext)
        @extensions << ext
        ext.transform(@transformers) if ext.respond_to?('transform')
      end

      def helper(helper)
        @helpers << helper
      end

      def transformer(transformer)
        @transformers << transformer
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

    end
  end
end
