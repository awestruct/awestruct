
require 'awestruct/deploy/github_pages_deploy'

describe Awestruct::Deploy::GitHubPagesDeploy do

  it "should be auto-registered" do
    Awestruct::Deployers.instance[ :github_pages ].should == Awestruct::Deploy::GitHubPagesDeploy
  end
end
