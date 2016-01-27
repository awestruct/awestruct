require 'fileutils'
require 'hashery'
require 'awestruct/handlers/file_handler'

describe Awestruct::Handlers::FileHandler do
  class TestTransformer
    def transform(site, page, rendered)
      rendered.gsub( /howdy/, 'adios' )
    end
  end 

  before :all do
    @site = Hashery::OpenCascade[ { :encoding=>false, :dir=>Pathname.new( test_data_dir '' )}]
    @site.engine = Hashery::OpenCascade[]
  end

  before :each do
    @filename = Pathname.new( test_data_dir 'simple-file.txt' )
    @handler = Awestruct::Handlers::FileHandler.new( @site, @filename )
    @page = Awestruct::Page.new( @site, @handler )
    @site.engine.pipeline = Awestruct::Pipeline.new
  end

  it "should be able to read a valid absolute file handler" do
    @handler.raw_content.strip.should == 'howdy'
  end

  it "should be able to read a valid relative file handler" do
    filename = Pathname.new( test_data_dir 'simple-file.txt' )
    pwd = Pathname.new( Dir.pwd )
    handler = Awestruct::Handlers::FileHandler.new( @site, filename.relative_path_from( pwd ) )
    handler.raw_content.strip.should == 'howdy'
  end

  it "should be stale before being read" do
    @handler.should be_stale
  end

  it "should not be stale after being read" do
    @handler.raw_content.strip.should == 'howdy'
    @handler.should_not be_stale
  end

  it "should be stale if touched after being read" do
    @handler.raw_content.strip.should == 'howdy'
    @handler.should_not be_stale
    sleep(1)
    FileUtils.touch( @filename )
    @handler.should be_stale
  end

  it "should provide reasonable paths" do
    @handler.relative_source_path.to_s.should == 'simple-file.txt'
    @handler.output_filename.should == 'simple-file.txt'
    @handler.output_extension.should == '.txt'
    @handler.output_path.to_s.should == './simple-file.txt'
  end

  it "should be able to create an appropriate context" do
    context = @page.create_context
    context.site.should == @site
    context.page.should == @page
    context.content.should == ''
  end

  it "should allow relative_source_path to be assignable" do
    @page.relative_source_path = '/taco'
    @page.relative_source_path.should == '/taco'
  end

  it "should not apply transformers, even if present" do
     @site.engine.pipeline.transformer TestTransformer.new
     @page.rendered_content.strip.should == 'howdy'
  end

end

