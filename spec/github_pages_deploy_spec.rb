
require 'awestruct/deploy/github_pages_deploy'

describe Awestruct::Deploy::GitHubPagesDeploy do

  before :each do
    site_config = mock
    site_config.stub(:output_dir).and_return '_site'

    deploy_config = mock
    deploy_config.stub(:[]).with('branch').and_return('the-branch')
    @deployer = Awestruct::Deploy::GitHubPagesDeploy.new( site_config, deploy_config )
  end

  it "should be auto-registered" do
    Awestruct::Deployers.instance[ :github_pages ].should == Awestruct::Deploy::GitHubPagesDeploy
  end

  it "should publish the site if there have been changes to the git repo" do
    git = mock
    git.stub_chain(:status, :changed, :empty?).and_return true
    ::Git.should_receive(:open).with('.').and_return git
    @deployer.should_receive(:publish_site)
    @deployer.run
  end

  it "should warn and noop if no changes have been committed" do
    git = mock
    git.stub_chain(:status, :changed, :empty?).and_return false
    ::Git.should_receive(:open).with('.').and_return git
    @deployer.should_receive(:message_for).with(:existing_changes)
    @deployer.run
  end
end
