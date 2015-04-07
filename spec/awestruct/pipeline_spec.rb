
require 'awestruct/pipeline'


describe Awestruct::Pipeline do
  before do
    dir = Pathname.new( test_data_dir 'engine' )
    opts = Awestruct::CLI::Options.new
    opts.source_dir = dir

    @site = Hashery::OpenCascade[ { :encoding=>false, :dir=>dir, :config=>Awestruct::Config.new( opts ) } ]
    Awestruct::Engine.new(@site.config)
  end

  it "should provide a way to find a matching handler chain for a given path" do
    pipeline = Awestruct::Pipeline.new
    pipeline.handler_chains[ "foot" ]
  end

end
