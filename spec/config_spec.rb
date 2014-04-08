require 'awestruct/config'
require 'spec_helper'
require 'awestruct/config'
require 'awestruct/cli/options'

describe Awestruct::Config do

  it "should accept a list of files in .awestruct_ignore to ignore on site generation" do
    site_dir = test_data_dir '' 
    opts = Awestruct::CLI::Options.new
    opts.source_dir = site_dir

    config = Awestruct::Config.new(opts)
    config.ignore.should == ["Rakefile", "Gemfile"]
  end

  it "should handle an empty .awestruct_ignore file without barfing" do
    site_dir = test_data_dir ''
    config_file = File.join(site_dir, ".awestruct_ignore")
    opts = Awestruct::CLI::Options.new
    opts.source_dir = site_dir
    File.open(config_file, "w")
    config = Awestruct::Config.new(opts)
    config.ignore.should == []
    File.open(config_file, "w") { |f| f.write("Rakefile\nGemfile\n") }
  end

end
