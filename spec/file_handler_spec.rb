require 'fileutils'
require 'hashery'
require 'awestruct/handlers/file_handler'

describe Awestruct::Handlers::FileHandler do

  before :all do
    @site = Hashery::OpenCascade[ { :encoding=>false, :dir=>Pathname.new( File.dirname( __FILE__ ) + '/test-data' ) } ]
  end

  it "should be able to read a valid absolute file handler" do
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler.raw_content.strip.should == 'howdy'
  end

  it "should be able to read a valid relative file handler" do
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    pwd = Pathname.new( Dir.pwd )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename.relative_path_from( pwd ) )
    handler.raw_content.strip.should == 'howdy'
  end

  it "should be stale before being read" do
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler.should be_stale
  end

  it "should not be stale after being read" do
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler.raw_content.strip.should == 'howdy'
    handler.should_not be_stale
  end

  it "should be stale if touched after being read" do
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler.raw_content.strip.should == 'howdy'
    handler.should_not be_stale
    sleep(1)
    FileUtils.touch( filename )
    handler.should be_stale
  end

  it "should provide reasonable paths" do
    filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename )
    handler.relative_source_path.should == '/simple-file.txt'
    handler.output_filename.should == 'simple-file.txt'
    handler.output_extension.should == '.txt'
    handler.output_path.should == '/simple-file.txt'
  end

end

