require 'spec_helper'

verify = lambda { |output|
   output.should == "<h3>Test</h3>"
}

theories =
  [
    {
      :page => "textile-page.textile",
      :simple_name => "textile-page",
      :syntax => :textile,
      :extension => '.html',
      :matcher => verify
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Textile" do

  it_should_behave_like "a handler", theories

end