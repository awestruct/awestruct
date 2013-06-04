require 'spec_helper'
require 'awestruct/extensions/minify'

describe Awestruct::Extensions::Minify do

  it "should ignore files with no extension" do
    site = mock
    page = mock

    site.should_receive(:minify).and_return true
    page.should_receive(:output_path).and_return "CNAME"
    input = "some input"

    minifier = Awestruct::Extensions::Minify.new
    minifier.transform(site, page, input).should == input
  end

  it "should compress html files" do
    site = mock
    page = mock

    site.should_receive(:minify).and_return true
    site.should_receive(:minify_html_opts).and_return( {:remove_comments => false} )
    page.should_receive(:output_path).any_number_of_times.and_return "test.html"

    input = "<html><a   href='' />  \n</html><!--test-->"
    expected_output = "<html><a href=''/> </html><!--test-->"

    minifier = Awestruct::Extensions::Minify.new [:html]
    minifier.transform(site, page, input).should == expected_output
  end

  # Doing this if it's production now
  #it "should compress css files" do
    #site = mock
    #page = mock

    #site.should_receive(:minify).and_return true
    #page.should_receive(:output_path).any_number_of_times.and_return "test.css"

    #input = ".class     { \n a: b   ;}"
    #expected_output = ".class{a:b}"

    #minifier = Awestruct::Extensions::Minify.new [:css]
    #minifier.transform(site, page, input).should == expected_output
  #end

  it "should compress js files" do
    site = mock
    page = mock

    site.should_receive(:minify).and_return true
    page.should_receive(:output_path).any_number_of_times.and_return "test.js"

    input = "function    a (a,     c) { \n a = \"a\";\n }"
    expected_output = "function a(a){a=\"a\"}" # we're minifying so we're going to strip dead or unreferenced code

    minifier = Awestruct::Extensions::Minify.new [:js]
    minifier.transform(site, page, input).should == expected_output
  end
end
