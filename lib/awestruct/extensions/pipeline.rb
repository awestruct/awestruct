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
    end

  end
end
    
