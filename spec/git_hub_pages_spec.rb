require 'spec_helper'
require 'awestruct/commands/git_hub_pages'

describe Awestruct::Commands::GitHubPages do

  before :each do
    @site_path = "_site"
    @git = double("git")
    @git.stub_chain(:status, :changed, :empty?) { true }
    @git.stub(:branch).and_return 'master'
    Git.stub(:open).with(".").and_return( @git )
    @github = Awestruct::Commands::GitHubPages.new( @site_path )
    @github.stub(:checkout_pages_branch)
    @github.stub(:add_and_commit_site)
    @github.stub(:push_and_restore)
  end

  it "should check for uncommitted changes" do
    @git.should_receive(:status) 
    @github.run
  end

  it "should checkout the gh-pages branch" do
    @github.should_receive(:checkout_pages_branch)
    @github.run
  end

  it "should accept an alternate branch name for publishing" do
    branch = double(:checkout=>true)
    github = Awestruct::Commands::GitHubPages.new( @site_path, 'master' )
    github.stub(:add_and_commit_site)
    github.stub(:push_and_restore)
    @git.should_receive(:branch).with('master').and_return(branch)
    github.run
  end

  it "should use the site_path as the working directory" do
    @github.should_receive(:add_and_commit_site).with(@site_path)
    @github.run
  end

  it "should push the updates and restore the current branch" do
    @github.should_receive(:push_and_restore).with('master')
    @github.run
  end

end
