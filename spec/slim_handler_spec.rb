# -*- coding: UTF-8 -*-
require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(<h1>This is a Slim page</h1>)
}

verify_atom = lambda { |output|
  output.should == '<?xml version="1.0" encoding="utf-8" ?><feed xmlns="http://www.w3.org/2005/Atom"><id>http://example.com</id><title>A News Feed</title></feed>'
}

verify_with_markdown = lambda { |output|
  output.should =~ %r(<h1[^>]*>Hello From Markdown</h1>)
}

verify_with_textile = lambda { |output|
  output.should =~ %r(<h1>Hello From Textile</h1>)
}

verify_with_utf8 = lambda { |output|
  output.should =~ %r(<h1>Besøg fra Danmark</h1>)
}

verify_with_variables = lambda { |output|
  output.should =~ %r(<h1>bacon</h1>)
}

theories =
    [
        {
            :page => 'slim-page.html.slim',
            :simple_name => 'slim-page',
            :syntax => :slim,
            :extension => '.html',
            :format => :html5,
            :matcher => verify
        },
        {
            :page => 'slim-page.xml.slim',
            :simple_name => 'slim-page',
            :syntax => :slim,
            :extension => '.xml',
            :format => :xhtml,
            :matcher => verify
        },
        {
            :page => 'slim-page.atom.slim',
            :simple_name => 'slim-page',
            :syntax => :slim,
            :extension => '.atom',
            :format => :xhtml,
            :matcher => verify_atom
        },
        {
            :page => 'slim-with-markdown-page.html.slim',
            :simple_name => 'slim-with-markdown-page',
            :syntax => :slim,
            :extension => '.html',
            :matcher => verify_with_markdown
        },
        {
            :page => 'slim-with-utf.html.slim',
            :simple_name => 'slim-with-utf',
            :syntax => :slim,
            :extension => '.html',
            :matcher => verify_with_utf8
        },
        {
            :page => 'slim-with-variables.html.slim',
            :simple_name => 'slim-with-variables',
            :syntax => :slim,
            :extension => '.html',
            :matcher => verify_with_variables
        }
    ]

describe Awestruct::Handlers::TiltHandler.to_s + '-Slim' do
  def additional_config
    { :crunchy => 'bacon' }
  end

  it_should_behave_like 'a handler', theories
end
