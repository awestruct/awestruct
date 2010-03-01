module Awestruct
  module Extensions

    class Pipeline

      attr_reader :extensions
      attr_reader :helpers

      def initialize(&block)
        @extensions = []
        @helpers    = []
        instance_eval &block if block
      end

      def extension(ext)
        @extensions << ext
      end

      def helper(helper)
        @helpers << helper
      end

      def execute(site)
        extensions.each do |ext|
          ext.execute( site )
        end
      end
    end

  end
end
    
