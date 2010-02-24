require 'awestruct'

module Awestruct
  module Commands
    class Generate

      def initialize(dir=Dir.pwd, force=false)
        @dir   = dir
        @force = force
        @engine = Awestruct::Engine.new( @dir )
      end

      def run()
        begin
          @engine.generate( @force )
        rescue =>e
          puts e
          puts e.backtrace
        end
      end
    end
  end
end
