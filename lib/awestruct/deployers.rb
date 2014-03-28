module Awestruct

  class Deployers < Hash
    def self.instance
      @instance ||= Deployers.new
    end

    def self.register( key, cls )
      Deployers.instance[ key.to_sym ] = cls
    end

  end

end
