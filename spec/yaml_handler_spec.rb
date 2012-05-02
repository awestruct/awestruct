
require 'hashery/open_cascade'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/yaml_handler'

describe Awestruct::Handlers::YamlHandler do

  before :all do
    @site = OpenCascade.new :encoding=>false
  end

  it "should provide access to the yaml as front-matter" do 
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-data.yaml" )
    file_handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler = Awestruct::Handlers::YamlHandler.new( @site, file_handler )
    handler.raw_content.should be_nil
    handler.front_matter['taco'].should == 'deluxe'
  end

end

