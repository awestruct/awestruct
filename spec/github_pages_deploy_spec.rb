
require 'awestruct/deploy/github_pages_deploy'

describe Awestruct::Deploy::GitHubPagesDeploy do

  before :each do
    site_config = mock
    site_config.stub(:output_dir).and_return '_site'

    deploy_config = mock
    deploy_config.stub(:[]).with('branch').and_return('the-branch')
    deploy_config.stub(:[]).with('repository').and_return('the-repo')
    @deployer = Awestruct::Deploy::GitHubPagesDeploy.new( site_config, deploy_config )

    @git = mock
    @git.stub_chain(:status, :changed, :empty?).and_return true
    ::Git.stub(:open).with('.').and_return @git
  end

  it "should be auto-registered" do
    Awestruct::Deployers.instance[ :github_pages ].should == Awestruct::Deploy::GitHubPagesDeploy
  end

  it "should publish the site if there have been changes to the git repo" do
    ::Git.should_receive(:open).with('.').and_return @git
    @deployer.should_receive(:publish_site)
    @deployer.run
  end

  it "should warn and noop if no changes have been committed" do
    @git.stub_chain(:status, :changed, :empty?).and_return false
    @deployer.should_receive(:message_for).with(:existing_changes)
    @deployer.run
  end

  it "should save and restore the current branch when publishing" do
    @git.should_receive(:current_branch).and_return( 'bacon' )
    @git.stub_chain(:branch, :checkout)
    @git.should_receive(:push).with('the-repo', 'the-branch')
    @git.should_receive(:checkout).with( 'bacon' )

    @deployer.stub(:add_and_commit_site)
    @deployer.run
  end
end
