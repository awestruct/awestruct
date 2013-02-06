require 'spec_helper'

verify = lambda { |output|
  output.should =~ /function\(\)/
  output.should =~ /call\(this\)/
}

theories =
  [
    {
      :page => "coffeescript-page.coffee",
      :simple_name => "coffeescript-page",
      :syntax => :coffeescript,
      :extension => '.js',
      :matcher => verify
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-CoffeeScript" do
  
  it_should_behave_like "a handler", theories

end