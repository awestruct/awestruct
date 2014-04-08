require 'spec_helper'

verify = lambda { |output|
  output.should =~ /\.class {\n  width: 2;\n}/
}

theories =
  [
    {
      :page => "less-page.less",
      :simple_name => "less-page",
      :syntax => :less,
      :extension => '.css',
      :matcher => verify
    },
    {
      :page => "less-page-with-import.less",
      :simple_name => "less-page-with-import",
      :syntax => :less,
      :extension => '.css',
      :matcher => verify,
      :unless => {
        :message => "Tilt 1.3.3 does not forward given options to Less parser. @import won't work unless :paths are set",
        :exp => lambda { Tilt::VERSION.eql? "1.3.3" }
      }
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Less" do
  
  it_should_behave_like "a handler", theories

end