require 'spec_helper'

verify_without_span = lambda { |output|
   output.should == "<h3>Test</h3>\n<p>the WHO</p>"
}

verify_with_span = lambda { |output|
   output.should == "<h3>Test</h3>\n<p>the <span class=\"caps\">WHO</span></p>"
}

theories =
  [
    {
      :page => "textile-page.textile",
      :simple_name => "textile-page",
      :syntax => :textile,
      :extension => '.html',
      :matcher => verify_without_span
    },
    {
      :page => "textile-page.textile",
      :simple_name => "textile-page",
      :syntax => :textile,
      :extension => '.html',
      :matcher => verify_with_span,
      :site_overrides => { :textile => { :no_span_caps => false } }
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Textile" do
  it_should_behave_like "a handler", theories
end
