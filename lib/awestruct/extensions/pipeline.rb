module Awestruct
  module Extensions

    class Pipeline

      attr_reader :extensions

      def initialize(&block)
        @extensions = []
        instance_eval &block if block
      end

      def extension(ext)
        @extensions << ext
      end

      def execute(site)
        extensions.each do |ext|
          ext.execute( site )
        end
      end
    end

  end
end
    
