# -*- coding: UTF-8 -*-
require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(var crunchy = "bacon")
}

theories =
    [
        {
            :page => 'javascript-page.js',
            :simple_name => 'javascript-page',
            :syntax => :javascript,
            :extension => '.js',
            :matcher => verify
        }
    ]


describe Awestruct::Handlers::TiltHandler.to_s + '-JavaScript' do
  def additional_config
    { :interpolate => true, :crunchy => 'bacon' }
  end

  it_should_behave_like 'a handler', theories
end