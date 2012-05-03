require 'spec_helper'
require 'fileutils'

require 'awestruct/page'
require 'awestruct/pipeline'
require 'awestruct/handlers/file_handler'

describe Awestruct::Handlers::FileHandler do

  class TestTransformer
    def transform(site, page, rendered)
      rendered.gsub( /howdy/, 'adios' )
    end
  end

  before :all do
    @site = OpenCascade.new :encoding=>false
    @site.engine = OpenCascade.new
  end

  before :each do
    @filename = Pathname.new( File.dirname(__FILE__) + "/test-data/simple-file.txt" )
    @handler = Awestruct::Handlers::FileHandler.new( @site, @filename )
    @page = Awestruct::Page.new( @site, @handler )
    @site.engine.pipeline = Awestruct::Pipeline.new
  end

  it "should be stale before being read" do
    @page.should be_stale
  end

  it "should not be stale after being read" do
    @page.raw_content.strip.should == 'howdy'
    @page.should_not be_stale
  end

  it "should be stale if touched after being read" do
    @page.raw_content.strip.should == 'howdy'
    @page.should_not be_stale
    sleep(1)
    FileUtils.touch( @filename )
    @page.should be_stale
  end

  it "should be able to create an appropriate context" do
    context = @page.create_context
    context.site.should == @site
    context.page.should == @page
    context.content.should == ''
  end

  it "should allow relative_source_path to be assignable" do
    @page.relative_source_path.should be_nil
    @page.relative_source_path = '/taco'
    @page.relative_source_path.should == '/taco'
  end

  it "should apply transformers if present" do
     @site.engine.pipeline.transformer TestTransformer.new
     @page.rendered_content.strip.should == 'adios'
  end


end

