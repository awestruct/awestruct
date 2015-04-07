require 'awestruct/engine'
require 'awestruct/pipeline' 

describe Awestruct::Pipeline do
  before do 
    dir = Pathname.new( test_data_dir 'pipeline' )
    opts = Awestruct::CLI::Options.new
    opts.source_dir = dir

    @site = Hashery::OpenCascade[ { :encoding=>false, :dir=>dir, :config=>Awestruct::Config.new( opts ), :pages => [] } ]
    @engine = Awestruct::Engine.new(@site.config)

    log = StringIO.new
    $LOG = Logger.new(log)
    $LOG.level = Logger::DEBUG 

    @engine.load_pipeline
    @pipeline = @engine.pipeline
  end

  context "after pipeline is loaded" do 
    specify "should have all specified extension points" do
      expect(@pipeline.before_pipeline_extensions.size).to eql 1
      expect(@pipeline.extensions.size).to eql 1
      expect(@pipeline.after_pipeline_extensions.size).to eql 1
      expect(@pipeline.helpers.size).to eql 1
      expect(@pipeline.transformers.size).to eql 1
      expect(@pipeline.after_generation_extensions.size).to eql 1
    end
  end

  it "should provide a way to find a matching handler chain for a given path" do
    pipeline = Awestruct::Pipeline.new
    pipeline.handler_chains[ "foot" ]
  end

end
