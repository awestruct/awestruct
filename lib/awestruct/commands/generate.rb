require 'awestruct'

module Awestruct
  module Commands
    class Generate

      def initialize(dir=Dir.pwd, base_url=nil, force=false)
        @dir   = dir
        @base_url = base_url
        @force = force
        @engine = Awestruct::Engine.new( @dir )
      end

      def run()
        begin
          @engine.generate( @base_url, @force )
        rescue =>e
          puts e
          puts e.backtrace
        end
      end
    end
  end
end
