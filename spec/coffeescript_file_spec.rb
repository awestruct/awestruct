require 'spec_helper'
require 'awestruct/coffeescript_file'
require 'awestruct/extensions/coffeescripttransform'

describe Awestruct::CoffeeScriptFile do
  before :all do
    @test_script = 'spec/test-coffee-script.coffee'
  end

  it "should compile coffeescript to javascript" do
    site = OpenStruct.new
    coffee = Awestruct::CoffeeScriptFile.new(site, File.expand_path(@test_script), @test_script)
    coffee.render(DummyContext.new)
  end

  class DummyContext
    def interpolate_string(string)
      return string
    end
  end
end

describe Awestruct::Extensions::CoffeeScriptTransform do
  before :all do
    @test_html = 'spec/test-coffee-script.html'
  end

  it "should compile coffeescript to javascript for inline html" do

    site = OpenStruct.new
    page = OpenStruct.new
    page.site = site
    page.output_path = File.expand_path(@test_html)

    coffee = Awestruct::Extensions::CoffeeScriptTransform.new
    transformed = coffee.transform(site, page, File.read(@test_html))

    html = Nokogiri::HTML(transformed, nil, 'UTF-8');

    verify(html, 'test_head_src', 'text/javascript', 'test.js')
    verify(html, 'test_head', 'text/javascript', nil)
    verify(html, 'test_inline_javascript', 'text/javascript', nil)
    verify(html, 'test_inline_coffeescript', 'text/javascript', nil)

  end

  private

  def verify(html, id, expected_type, expected_src)
    script = html.xpath("//script[@id='#{id}']")
    script.attr('type').to_s.should == expected_type
    if !expected_src.nil?
      script.attr('src').to_s.should == expected_src
    end
  end
end
