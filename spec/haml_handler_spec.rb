# -*- coding: UTF-8 -*-
require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(<h1>This is a HAML page</h1>)
}

verify_atom = lambda { |output|
  output.should == %(<?xml version="1.0" encoding="utf-8" ?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <id>http://example.com</id>
  <title>A News Feed</title>
</feed>
)
}

verify_with_markdown = lambda { |output|
  output.should =~ %r(<h1[^>]*?>Hello From Markdown</h1>)
}

verify_with_textile = lambda { |output|
  output.should =~ %r(<h1>Hello From Textile</h1>)
}

verify_with_utf8 = lambda { |output|
  output.should == "<h1>Besøg fra Danmark</h1>\n"
}

verify_with_variables = lambda { |output|
  output.should =~ %r(<h1>bacon</h1>)
}

theories =
  [
    {
      :page => "haml-page.html.haml",
      :simple_name => "haml-page",
      :syntax => :haml,
      :extension => '.html',
      :format => :html5,
      :matcher => verify
    },
    {
      :page => "haml-page.xml.haml",
      :simple_name => "haml-page",
      :syntax => :haml,
      :extension => '.xml',
      :format => :xhtml,
      :matcher => verify
    },
    {
      :page => 'haml-page.atom.haml',
      :simple_name => 'haml-page',
      :syntax => :haml,
      :extension => '.atom',
      :format => :xhtml,
      :matcher => verify_atom
    },
    {
      :page => "haml-with-markdown-page.html.haml",
      :simple_name => "haml-with-markdown-page",
      :syntax => :haml,
      :extension => '.html',
      :matcher => verify_with_markdown
    },
    {
      :page => "haml-with-textile-page.html.haml",
      :simple_name => "haml-with-textile-page",
      :syntax => :haml,
      :extension => '.html',
      :matcher => verify_with_textile
    },
    {
      :page => "haml-with-utf.html.haml",
      :simple_name => "haml-with-utf",
      :syntax => :haml,
      :extension => '.html',
      :matcher => verify_with_utf8
    },
    {
      :page => "haml-with-variables.html.haml",
      :simple_name => "haml-with-variables",
      :syntax => :haml,
      :extension => '.html',
      :matcher => verify_with_variables
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Haml" do
  let(:additional_config) { {:crunchy => 'bacon'} }
  it_should_behave_like "a handler", theories

end
