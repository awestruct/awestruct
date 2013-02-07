require 'spec_helper'

verify = lambda { |output|
   output.should =~ /#test \{/
   output.should =~ /background-color: #ce4dd6; \}/
}

theories =
  [
    {
      :page => "sass-page.sass",
      :simple_name => "sass-page",
      :syntax => :sass,
      :extension => '.css',
      :matcher => verify
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Sass" do

  it_should_behave_like "a handler", theories

end