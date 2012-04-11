require 'spec_helper'
require 'awestruct/commands/git_hub_pages'

describe Awestruct::Commands::GitHubPages do

  before :each do
    @site_path = "_site"
    @git = double("git")
    Git.stub(:open).with(".").and_return( @git )
    @github = Awestruct::Commands::GitHubPages.new( @site_path )
  end

  it "should check for the gh-pages branch" do
    @git.should_receive(:is_branch?).with('gh-pages')
    @github.run
  end

  it "should return false if the gh-pages branch does not exist" do
    @git.should_receive(:is_branch?).with('gh-pages').and_return false
    @github.run.should be_false
  end

  describe "with an existing gh-pages branch" do
    before :each do
      @git.stub(:branch).and_return 'master'
      @git.stub(:push).with('origin', 'gh-pages')
      @git.stub(:checkout).with('master')
      @git.stub(:is_branch?).with('gh-pages').and_return true
      @git.stub(:with_working).with(@site_path).and_yield
      @git.stub(:checkout).with('gh-pages').and_return true
      @git.stub(:add).with('.').and_return true
      @git.stub(:commit).with("Published to gh-pages.").and_return true
      @git.stub(:reset_hard).and_return true
      @git.stub_chain(:status, :changed, :empty?) { true }
    end

    it "should check for uncommitted changes" do
      @git.should_receive(:status) 
      @github.run
    end

    it "should checkout the gh-pages branch" do
      @git.should_receive(:checkout).with('gh-pages').and_return true
      @github.run
    end

    it "should use the site_path as the working directory" do
      @git.should_receive(:with_working).with(@site_path).and_return true
      @github.run
    end

    it "should add the generated files to the index" do
      @git.should_receive(:add).with('.')
      @github.run
    end

    it "should commit the index" do
      @git.should_receive(:commit).with('Published to gh-pages.')
      @github.run
    end

    it "should reset the current working directory" do
      @git.should_receive(:reset_hard)
      @github.run
    end

    it "should push the changes" do
      @git.should_receive(:push).with('origin', 'gh-pages')
      @github.run
    end

    it "should checkout the original working branch when done" do
      @git.should_receive(:checkout).with('master')
      @github.run
    end

  end

end
