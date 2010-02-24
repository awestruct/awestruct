require 'ostruct'

module Awestruct
  class Renderable < OpenStruct

    attr_reader :site

    def initialize(site)
      super( {} )
      @site = site
    end

    def render(context)
      puts ''
    end

  end
end
