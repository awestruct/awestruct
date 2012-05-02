require 'fileutils'

require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'

describe Awestruct::Handlers::FrontMatterHandler do

  before :all do
    @site = OpenCascade.new :encoding=>false
  end

  before :each do
  end

  def file_input(filename)
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/#{filename}" )
    Awestruct::Handlers::FileHandler.new( @site, filename )
  end

  it "should be able to split front-matter from content" do 
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input( "front-matter-file.txt" ) )
    handler.front_matter.should_not be_nil
    handler.front_matter['foo'].should == 'bar'
    handler.raw_content.strip.should == 'This is some content'
  end

  it "should be able to split front-matter from content for files without actual front-matter" do 
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input( "front-matter-file-no-front.txt" ) )
    handler.front_matter.should_not be_nil
    handler.front_matter.should be_empty
    handler.raw_content.strip.should == 'This is some content'
  end

  it "should be able to split front-matter from content for files without actual content" do 
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input( "front-matter-file-no-content.txt" ) )
    handler.front_matter.should_not be_nil
    handler.front_matter['foo'].should == 'bar'
    handler.raw_content.should be_nil
  end

end

