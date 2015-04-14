require 'awestruct/astruct'

module Awestruct

  class Context < Awestruct::AStruct
    attr_accessor :site
    attr_accessor :page

    def initialize(hash)
      super
      @page = hash[:page]
      @site = hash[:site]

      # Update the front matter from the handler chain
      @page.handler.front_matter.each do |k,v|
        k_sym = k.to_sym
        @page[k_sym] = v if @page.key? k_sym
      end
    end

    def inspect
      "Awestruct::Context{:page=>#{self.page.inspect}}"
    end
  end

end
