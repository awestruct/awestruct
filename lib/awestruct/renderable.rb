module Awestruct
  class Renderable < Page

    def initialize(site)
      super( {} )
      @site = site
    end

    def render(context)
      puts ''
    end

  end
end
