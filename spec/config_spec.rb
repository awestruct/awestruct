require 'awestruct/config'
require 'spec_helper'

describe Awestruct::Config do

  it "should accept a list of files in .awestruct_ignore to ignore on site generation" do
    site_dir = File.join(File.dirname(__FILE__), 'test-data')
    config = Awestruct::Config.new(site_dir)
    config.ignore.should == ["Rakefile", "Gemfile"]
  end

  it "should handle an empty .awestruct_ignore file without barfing" do
    site_dir = File.join(File.dirname(__FILE__), 'test-data')
    config_file = File.join(site_dir, ".awestruct_ignore")
    File.open(config_file, "w")
    config = Awestruct::Config.new(site_dir)
    config.ignore.should == []
    File.open(config_file, "w") { |f| f.write("Rakefile\nGemfile\n") }
  end

end
