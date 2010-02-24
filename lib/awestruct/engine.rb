module Awestruct

  IGNORE_NAMES = [
    'hekyll',
  ]

  class Engine

    def initialize(dir)
      @dir = dir
      @site = Site.new( @dir )
    end

    def generate()
      @site.generate
    end
  end

end
