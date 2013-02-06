require 'spec_helper'
require 'org-ruby'

verify = lambda { |output|
   output.should =~ %r(<h1 class="title">Fruit</h1>)
   output.should =~ %r(<p>Apples are red</p>)
}

theories =
  [
    {
      :page => "orgmode-page.org",
      :simple_name => "orgmode-page",
      :syntax => :orgmod,
      :extension => '.html',
      :matcher => verify
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-OrgMode" do

  it_should_behave_like "a handler", theories

end