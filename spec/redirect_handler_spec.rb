require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0;url=http://google.com"></head></html>)
}
verify_with_interpol = lambda { |output|
  output.should =~ %r(<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0;url=http://mysite/bacon/"></head></html>)
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
  def additional_config
    { :interpolate => true, :crunchy => 'bacon', :base_url => 'http://mysite' }
  end

  it_should_behave_like "a handler", theories

end
