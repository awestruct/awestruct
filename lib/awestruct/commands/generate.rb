require 'awestruct'

module Awestruct
  module Commands
    class Generate

      def initialize(dir=Dir.pwd)
        @dir = dir
      end

      def run()
        engine = Awestruct::Engine.new( @dir )

        begin
          engine.generate
        rescue =>e
          puts e
          puts e.backtrace
        end
      end
    end
  end
end
