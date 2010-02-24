require 'ostruct'

module Awestruct 
  class Page < OpenStruct

    def initialize(site)
      super({ :site=>site })
    end

  end
end
