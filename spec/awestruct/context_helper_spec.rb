require 'spec_helper'
require 'awestruct/context_helper'

class Tester
  include Awestruct::ContextHelper
end

describe Awestruct::ContextHelper do
  before :each do
    @tester = Tester.new
  end

  describe "html_to_text" do

    it "should strip HTML tags" do
      str = "<h1>A Title</h1>"
      @tester.html_to_text(str).should == "A Title"
    end

    it "should replace &nbsp; with a space" do
      str = "foo&nbsp;bar"
      @tester.html_to_text(str).should == "foo bar"
    end
  end

  describe "clean_html" do
    # this is an odd, less useful version of html_to_text
    it "should replace &nbsp; with a space" do
      str = "foo&nbsp;bar"
      @tester.clean_html(str).should == "foo bar"
    end
  end

  describe "without_images" do
    it "should remove image tags, but not other tags" do
      str = "<h1>Hello!</h1><img src='images/foo'/>"
      @tester.without_images(str).should == "<h1>Hello!</h1>"
    end

    it "should remove surrounding anchor tags if they exist" do
      str = "<h1>Hello!</h1><a href='foobar'><img src='images/foo'/></a>"
      @tester.without_images(str).should == "<h1>Hello!</h1>"
    end

    it "should not remove anchor tags around text" do
      str = "<h1>Hello!</h1><a href='foobar'>foobar</a>"
      @tester.without_images(str).should == "<h1>Hello!</h1>foobar"
    end
  end

  describe "close_tags" 

  describe "summarize" do

    before :all do
      @long_string = "Once upon a time there was a horse who loved apples. He loved them so much that he ate one every day."
    end

    it "should shorten a string to 20 words by default" do
      @tester.summarize(@long_string).split(/ /).size.should == 20
    end

    it "should append the shortened string with an ellipses" do
      @tester.summarize(@long_string)[-3..-1].should == "..."
    end

    it "should allow customization of the number of words" do
      @tester.summarize(@long_string, 10).split(/ /).size.should == 10
    end

    it "should allow customization of the appended ellipses" do
      @tester.summarize(@long_string, 5, "---")[-3..-1].should == "---"
    end
  end

  describe "fully_qualify_urls" do
    it "should fix anchor tags" do
      str = "<a href='/foo'>foobar</a>"
      @tester.fully_qualify_urls('http://foobar.com', str).should == %q(<a href="http://foobar.com/foo">foobar</a>)
    end

    it "should fix link tags" do
      str = "<link href='/foo'>"
      @tester.fully_qualify_urls('http://foobar.com', str).should == %q(<link href="http://foobar.com/foo" />)
    end

    it "should fix image tags" do
      str = "<img src='/foo' />"
      @tester.fully_qualify_urls('http://foobar.com', str).should == %q(<img src="http://foobar.com/foo" />)
    end

    it "should leave anchor tags with no href attribute (for page anchors) unchanged" do
      str = %q(<a target="#foo">foobar</a>)
      @tester.fully_qualify_urls('http://foobar.com', str).should == str
    end
  end

  describe "fix_url" do # This method is simple minded and dresses funny

    it "should return a fully qualified url unchanged" do
      str = "http://foobar.com/foo/bar"
      @tester.fix_url("http://foobar.com", str).should == str
    end

    it "should prepend the schema and hostname if required" do
      str = "http://foobar.com/foo/bar"
      @tester.fix_url("http://foobar.com", "/foo/bar").should == str
    end

  end

end

