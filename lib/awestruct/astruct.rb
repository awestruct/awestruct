require 'awestruct/astruct_mixin'

module Awestruct

  class AStruct < Hash

    include AStructMixin

    def initialize(hash=nil)
      hash.each{|k,v| self[k]=v } if hash
    end

    alias_method :original_entries, :entries
    undef entries

    def inspect
      "AStruct{...}"
    end
  
  end

end
