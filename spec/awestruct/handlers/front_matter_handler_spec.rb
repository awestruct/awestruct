# -*- coding: UTF-8 -*-

require 'fileutils'
require 'spec_helper'

require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'hashery'

describe Awestruct::Handlers::FrontMatterHandler do

  before :all do
    @site = Hashery::OpenCascade[ {  :encoding=>false } ]
  end

  before :each do
  end

  def file_input(filename)
    filename = Pathname.new( test_data_dir filename )
    Awestruct::Handlers::FileHandler.new( @site, filename )
  end

  it 'should be able to split front-matter from content' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-file.txt') )
    handler.front_matter.should_not be_nil
    handler.front_matter['foo'].should == 'bar'
    handler.raw_content.strip.should == 'This is some content'
  end

  it 'should be able to split empty front-matter from content' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-empty.txt') )
    handler.front_matter.should == {} 
    handler.raw_content.strip.should == 'This is some content'
  end

  it 'should be able to split front-matter from content for files without actual front-matter' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-file-no-front.txt') )
    handler.front_matter.should_not be_nil
    handler.front_matter.should be_empty
    handler.raw_content.strip.should == 'This is some content'
  end

  it 'should be able to split front-matter from content for files without actual content' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-file-no-content.txt') )
    handler.front_matter.should_not be_nil
    handler.front_matter['foo'].should == 'bar'
    handler.raw_content.should be_nil
  end

  it 'should not match front matter in the middle of a file' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-middle.txt') )
    handler.front_matter.should_not be_nil
    handler.front_matter.should be_empty
    handler.raw_content.should_not be_nil
  end

  it 'should not mistake horizontal rule for front matter' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-looking.txt') )
    handler.front_matter.should_not be_nil
    handler.front_matter.should be_empty
    handler.raw_content.should_not be_nil
  end

  it 'should be able to handle UTF-8 characters' do
    handler = Awestruct::Handlers::FrontMatterHandler.new( @site, file_input('front-matter-file-utf8.txt') )
    handler.front_matter.should_not be_nil
    handler.front_matter['foo'].should == 'bar'
    handler.front_matter['utf8-content'].should == 'Μεα ιυδισο μενθιτυμ ετ. Ιυς ευ ποπυλω'
    handler.raw_content.should_not be_nil
  end

end

