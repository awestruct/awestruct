require 'spec_helper'

verify = lambda { |output|
   output.should =~ /#test \{/
   output.should =~ /background-color: #ce4dd6; \}/
}

theories =
  [
    {
      :page => "scss-page.scss",
      :simple_name => "scss-page",
      :syntax => :scss,
      :extension => '.css',
      :matcher => verify
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Scss" do

  it_should_behave_like "a handler", theories

end