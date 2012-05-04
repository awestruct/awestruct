require 'spec_helper'

describe Awestruct::Config do

  it "should accept a list of files in .awestruct_ignore to ignore on site generation" do
    site_dir = File.join(File.dirname(__FILE__), 'test-data')
    config = Awestruct::Config.new(site_dir)
    config.ignore.should == ["Rakefile", "Gemfile"]
  end

end
