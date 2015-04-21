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
        if @page.key? k_sym
          if @page[k_sym].is_a? Array
            page_values = @page[k_sym].collect {|v| v.class}.sort
            front_matter_values = v.collect {|v| v.class}.sort
            @page[k_sym] = v if page_values.eql? front_matter_values
          elsif @page[k_sym].is_a? Hash
            page_values = @page[k_sym].collect {|k, v| v.class}.sort
            front_matter_values = v.collect {|k, v| v.class}.sort
            @page[k_sym] = v if page_values.eql? front_matter_values
          else
            @page[k_sym] = v if @page.key?(k_sym) && (@page[k_sym].class == v.class)
          end
        end
      end
    end

    def inspect
      "Awestruct::Context{:page=>#{self.page.inspect}}"
    end
  end

end
