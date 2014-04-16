
require 'awestruct/pipeline'


describe Awestruct::Pipeline do

  it "should provide a way to find a matching handler chain for a given path" do
    pipeline = Awestruct::Pipeline.new
    pipeline.handler_chains[ "foot" ]
  end

end
