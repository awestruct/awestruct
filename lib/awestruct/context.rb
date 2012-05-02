
require 'awestruct/astruct'

module Awestruct

  class Context < Awestruct::AStruct
    attr_accessor :site
    attr_accessor :page

    def initialize(hash)
      super 
      @page = hash[:page]
      @site = hash[:site]
     
    end 

    def inspect
      "Awestruct::Context{:page=>#{self.page.inspect}}" 
    end  
  end

end
