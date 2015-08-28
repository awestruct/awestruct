require 'awestruct/astruct_mixin'

module Awestruct

  class AStruct < Hash

    include AStructMixin

    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
      undef org, com, java, javax, javafx # Issue #480
    end

    def initialize(hash=nil)
      hash.each{|k,v| self[k]=v } if hash
    end

    alias_method :original_entries, :entries
    undef entries

    def inspect
      "AStruct{...}"
    end

    def hash()
      self.output_path.hash
    end

  end

end
