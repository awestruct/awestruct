
module Awestruct

  class HandlerChain

    attr_reader :matcher
    attr_reader :handler_classes

    def initialize(matcher, *handler_classes)
      @matcher         = matcher
      @handler_classes = handler_classes
    end

    def matches?(path)
      @matcher.match( path )
    end

    def create(site, path)
      cur = path
      @handler_classes.each do |cls|
        cur = cls.new( site, cur )
      end
      cur
    end

  end

end
