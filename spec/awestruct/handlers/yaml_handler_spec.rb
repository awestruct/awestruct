
require 'hashery'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/yaml_handler'

describe Awestruct::Handlers::YamlHandler do

  before :all do
    @site = Hashery::OpenCascade[ { :encoding=>false } ]
  end

  it "should provide access to the yaml as front-matter" do 
    filename = Pathname.new( test_data_dir 'simple-data.yaml' )
    file_handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler = Awestruct::Handlers::YamlHandler.new( @site, file_handler )
    handler.raw_content.should be_nil
    handler.front_matter['taco'].should == 'deluxe'
  end

end

