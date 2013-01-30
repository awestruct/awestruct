require 'spec_helper'

verify = lambda { |output|
   #output.should == "<h3>Test</h3>" ? unknown
}

theories =
  [
    {
      :page => "restructuredtext-page.rst",
      :simple_name => "restructuredtext-page",
      :syntax => :rst,
      :extension => '.html'
      #:matcher => verify ? requires rst2html command line tool
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-reStructuredText" do

  it_should_behave_like "a handler", theories

end