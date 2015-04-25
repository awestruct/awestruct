require 'nokogiri'

module NokogiriMatchers
  class HtmlMatchers
    def initialize(tag)
      @tag = tag.to_s
    end
    def matches?(document)
      @document = Nokogiri::HTML.fragment document
      !@document.search(@tag).nil?
    end

    def failure_message
      "expected to find #{@tag} within #{@document.to_s} but was not found"
    end
  end

  def have_tag(expect)
    HtmlMatchers.new(expect)
  end
end

RSpec.configure do |c|
  c.include NokogiriMatchers
end
