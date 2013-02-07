require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(<head><meta http-equiv="location" content="URL=http://google.com" /></head>)
}
verify_with_interpol = lambda { |output|
  output.should =~ %r(<head><meta http-equiv="location" content="URL=http://bacon.com" /></head>)
}

theories =
  [
    {
      :page => "simple-redirect-page.redirect",
      :simple_name => "simple-redirect-page",
      :syntax => :text,
      :extension => '.html',
      :matcher => verify
    },
    {
      :page => "redirect-page.redirect",
      :simple_name => "redirect-page",
      :syntax => :text,
      :extension => '.html',
      :matcher => verify_with_interpol
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Redirect" do
  let(:additional_config) { {:interpolate => true, :crunchy => "bacon"} }
  it_should_behave_like "a handler", theories

end