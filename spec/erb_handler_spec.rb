# -*- coding: UTF-8 -*-
require 'spec_helper'
require 'rbconfig'

verify = lambda { |output|
  output.should =~ %r(<h1>This is an ERB page</h1>)
  output.should =~ %r(<h2>The fruit of the day is: apples</h2>)
  output.should =~ %r(<h3>bacon</h3>) ## interpolated
}

verify_with_xml = lambda { |output|
  output.should =~ %r(<h>bacon</h>) ## interpolated
}

verify_with_utf8 = lambda { |output|
  if RbConfig::CONFIG['target_os'] !~ /mswin|mingw/
    output.should == "Besøg fra Danmark\n"
  else
    output.should == "\r\nBesøg fra Danmark\r\n"
  end
}

theories =
    [
        {
            :page => 'erb-page.html.erb',
            :simple_name => 'erb-page',
            :syntax => :erb,
            :extension => '.html',
            :matcher => verify
        },
        {
            :page => 'erb-page.xml.erb',
            :simple_name => 'erb-page',
            :syntax => :erb,
            :extension => '.xml',
            :matcher => verify_with_xml
        },
        {
            :page => 'erb-utf-page.html.erb',
            :simple_name => 'erb-utf-page',
            :syntax => :erb,
            :extension => '.html',
            :matcher => verify_with_utf8
        }
    ]

describe Awestruct::Handlers::TiltHandler.to_s + '-Erb' do
  def additional_config
    { :crunchy => 'bacon' }
  end
  it_should_behave_like 'a handler', theories

end
