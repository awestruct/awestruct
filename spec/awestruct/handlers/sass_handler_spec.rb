require 'spec_helper'

verify = lambda { |output|
  output.should =~ /#test\s*\{\s*background-color:\s*#ce4dd6;\s*\}/
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
