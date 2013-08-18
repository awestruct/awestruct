require 'spec_helper'
require 'awestruct/deploy/github_pages_deploy'

describe Awestruct::Deploy::GitHubPagesDeploy do

  before :each do
    site_config = mock
    site_config.stub(:output_dir).and_return '_site'

    @deploy_config = mock
    @deploy_config.stub(:[]).with('branch').and_return('the-branch')
    @deploy_config.stub(:[]).with('repository').and_return('the-repo')
    @deploy_config.stub(:[]).with('gzip').and_return('false')
    @deploy_config.stub(:[]).with('gzip_level')
    @deploy_config.stub(:[]).with('scm').and_return('git')
    @deploy_config.stub(:[]).with('source_dir').and_return('.')
    @deploy_config.stub(:[]).with('uncommitted').and_return('false')
    @deployer = Awestruct::Deploy::GitHubPagesDeploy.new( site_config, @deploy_config )

    @git = mock
    @git.stub_chain(:status, :changed, :empty?).and_return true
    ::Git.stub(:open).with('.').and_return @git
  end

  it "should be auto-registered" do
    Awestruct::Deployers.instance[ :github_pages ].should == Awestruct::Deploy::GitHubPagesDeploy
  end

  it "should warn and noop if no changes have been committed" do
    git_scm = mock()
    git_scm.stub(:uncommitted_changes?).with('.').and_return true
    @deployer.instance_variable_set('@scm', git_scm)
    $LOG.should_receive(:error).with(Awestruct::Deploy::Base::UNCOMMITTED_CHANGES)
    @deployer.run
  end

  it "should save and restore the current branch when publishing" do
    git_scm = mock()
    git_scm.stub(:uncommitted_changes?).with('.').and_return false
    @deployer.instance_variable_set('@scm', git_scm)
    @git.should_receive(:current_branch).and_return( 'bacon' )
    @git.stub_chain(:branch, :checkout)
    @git.should_receive(:push).with('the-repo', 'the-branch')
    @git.should_receive(:checkout).with( 'bacon' )

    @deployer.stub(:add_and_commit_site)
    @deployer.run
  end

  it "should save and restore the current detached branch when publishing" do
    git_scm = mock()
    git_scm.stub(:uncommitted_changes?).with('.').and_return false
    @deployer.instance_variable_set('@scm', git_scm)
    @git.should_receive(:current_branch).and_return( '(no branch)' )
    @git.stub_chain(:log, :first, :sha).and_return( '0123456789' )
    @git.should_receive(:branch).with('__awestruct_deploy__').and_return @git
    @git.should_receive(:checkout)
    @git.should_receive(:branch).with('the-branch').and_return @git
    @git.should_receive(:checkout)
    @git.should_receive(:push).with('the-repo', 'the-branch')
    @git.should_receive(:checkout).with( '0123456789' )
    @git.should_receive(:branch).with('__awestruct_deploy__').and_return @git
    @git.should_receive(:delete)

    @deployer.stub(:add_and_commit_site)
    @deployer.run
  end
end
