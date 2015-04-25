require 'nokogiri'

module EmmetMatchers
  class EmmetStructureMatcher
    def initialize(emmet_string)
      @test_string = emmet_string
    end

    def matches?(html_snippet)
      frag = Nokogiri::HTML.fragment html_snippet
      emmet_string = ''
      elem_stack = []
      frag.traverse {|node| elem_stack.push node unless node.text?}

      until elem_stack.empty? do
        elem = elem_stack.pop
        unless elem.name == '#document-fragment' || elem.text.rstrip.empty?
          emmet_string << elem.name unless elem.text.chop.empty?
          if elem.attr('id')
            emmet_string << "#{'#'}#{elem.attr('id')}"
          end
          if elem.attr('class')
            emmet_string << ".#{elem.attr('class')}"
          end
          if elem.child
            child = elem.child
            #if child.text? && !child.text.rstrip.empty?
            #emmet_string << "{#{child.text.gsub(/\s+/, ' ')}}"
            #elem_stack.delete child
            #end
            elem_stack.delete child
            emmet_string << '>' unless elem_stack.last.nil?
            next
          end
        end
      end

      @emmet_string = emmet_string

      @emmet_string == @test_string 
    end

    def failure_message
      "expected to match #{@test_string} against #{@emmet_string}, but they are not equal"
    end 
  end

  def have_structure(expect)
    EmmetStructureMatcher.new(expect)
  end
end

RSpec.configure do |c|
  c.include EmmetMatchers
end
