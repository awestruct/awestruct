require 'spec_helper'
require 'awestruct/deploy/base_deploy'

describe Awestruct::Deploy::Base do
  before :each do
    @site_config = double
    @site_config.stub(:output_dir).and_return '_site'

    @deploy_config = double
    @deploy_config.stub(:[]).with('branch').and_return('the-branch')
    @deploy_config.stub(:[]).with('repository').and_return('the-repo')
    @deploy_config.stub(:[]).with('gzip').and_return('false')
    @deploy_config.stub(:[]).with('gzip_level')
    @deploy_config.stub(:[]).with('scm').and_return('git')
    @deploy_config.stub(:[]).with('source_dir').and_return('.')
    @deploy_config.stub(:[]).with('uncommitted').and_return('false') 
    Awestruct::ExceptionHelper.class_variable_set :@@failed, false
  end 

  it "should not run if the build failed" do 
    log = StringIO.new
    $LOG = Logger.new(log)
    $LOG.level = Logger::DEBUG 
    Awestruct::ExceptionHelper.mark_failed 

    deployer = Awestruct::Deploy::Base.new(@site_config, @deploy_config)
    deployer.run
    expect(log.string).to include('Not running deploy due to build failure')
  end
end
