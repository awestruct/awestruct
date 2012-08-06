
require 'awestruct/cli/deploy'

describe Awestruct::CLI::Deploy do

  it "should use a given deploy[:type]" do
    deployer = Awestruct::CLI::Deploy.new({}, {'type' => :foo})
    deployer.deploy_type.should == :foo
  end

  it "should use rsync if no deploy[:type] is given" do
    deployer = Awestruct::CLI::Deploy.new({}, {})
    deployer.deploy_type.should == :rsync
  end

  it "should use github_pages if deploy['host'] is github_pages and no deploy[:type] is given" do
    deployer = Awestruct::CLI::Deploy.new({}, {'host' => :github_pages})
    deployer.deploy_type.should == :github_pages
  end

  it "should use a given deploy['type'] even if deploy['host'] is github_pages" do
    deployer = Awestruct::CLI::Deploy.new({}, {'type' => :foo, 'host'=>:github_pages})
    deployer.deploy_type.should == :foo
  end

  it "should work with strings for keys" do
    deployer = Awestruct::CLI::Deploy.new({}, {'host' => :github_pages})
    deployer.deploy_type.should == :github_pages
  end

  it "should work with strings for values" do
    deployer = Awestruct::CLI::Deploy.new({}, {'host' => 'github_pages'})
    deployer.deploy_type.should == :github_pages
  end

end
