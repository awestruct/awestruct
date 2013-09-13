require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(<h1>This is a Mustache page</h1>)
}

theories =
  [
    {
      :page => 'mustache-page.html.mustache',
      :simple_name => 'mustache-page',
      :syntax => :mustache,
      :extension => '.html',
      :matcher => verify,
      :site_overrides => { :markup_type => 'Mustache' }
    },
    {
      :page => 'mustache-page.xml.mustache',
      :simple_name => 'mustache-page',
      :syntax => :mustache,
      :extension => '.xml',
      :matcher => verify,
      :site_overrides => { :markup_type => 'Mustache' }
    }
  ]


describe Awestruct::Handlers::TiltHandler.to_s + '-Mustache' do
  it_should_behave_like 'a handler', theories
end
