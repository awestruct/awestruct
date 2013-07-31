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
      :matcher => verify
    },
    {
      :page => 'mustache-page.xml.mustache',
      :simple_name => 'mustache-page',
      :syntax => :mustache,
      :extension => '.xml',
      :matcher => verify
    }
  ]


describe Awestruct::Handlers::TiltHandler.to_s + '-Mustache' do
  def additional_config
    {:markup_type => 'Mustache'}
  end

  it_should_behave_like 'a handler', theories

end