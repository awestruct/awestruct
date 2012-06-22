require 'spec_helper'
require 'awestruct/extensions/minify'

describe Awestruct::Extensions::Minify do
  before :all do
    @minifier = Awestruct::Extensions::Minify.new
  end

  it "should ignore files with no extension" do
    site = mock
    site.should_receive(:minify).and_return true
    page = mock
    page.should_receive(:output_path).and_return "CNAME"
    input = "some input"
    @minifier.transform(site, page, input).should == input
  end

end
