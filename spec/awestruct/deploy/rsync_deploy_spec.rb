
require 'awestruct/deploy/rsync_deploy'

describe Awestruct::Deploy::RSyncDeploy do

  it "should be auto-registered" do
    Awestruct::Deployers.instance[ :rsync ].should == Awestruct::Deploy::RSyncDeploy
  end
end
