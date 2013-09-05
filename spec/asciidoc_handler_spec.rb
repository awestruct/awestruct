require 'spec_helper'
require 'rspec/matchers.rb'

verify = lambda { |output|
  include EmmetMatchers
  # clean whitespace to make comparison easier
  output.should have_structure('div#preamble>div.sectionbody>div.paragraph>p>strong')
}

verify_front_matter = lambda { |output, page|
  page.title.should == 'AwestructAsciiDoc'
  output.should_not =~ %r(title: AwestructAsciiDoc)
}

verify_headers = lambda { |output, page|
  extend RSpec::Matchers
  page.author.should == 'Stuart Rackham'
  page.title.should == 'AsciiDoc'
  page.doctitle.should == 'AsciiDoc'
  page.name.should == 'Awestruct'
  page.layout.should == 'haml-layout'
  page.tags.should be_a_kind_of(Array)
  page.tags.should == %w(a b c)
  page.date.should be_a_kind_of(Date)
  output.should =~ %r(This is <strong>AsciiDoc</strong> in Awestruct.)
  output.should =~ %r(#{Awestruct::VERSION})
}

verify_attributes = lambda { |output, page|
  include RSpec::Matchers
  expect(output).to BuiltIn::Include.new("docname=#{page.simple_name};")
  expect(output).to BuiltIn::Include.new("docfile=#{File.expand_path page.source_path};")
  expect(output).to BuiltIn::Include.new("docdir=#{File.expand_path File.dirname(page.source_path)};")
}

theories =
    [
        {
            :page => 'asciidoc-page.ad',
            :simple_name => 'asciidoc-page',
            :syntax => :asciidoc,
            :extension => '.html',
            :matcher => verify
        },
        {
            :page => 'asciidoc-page.adoc',
            :simple_name => 'asciidoc-page',
            :syntax => :asciidoc,
            :extension => '.html',
            :matcher => verify
        },
        {
            :page => 'asciidoc-page.asciidoc',
            :simple_name => 'asciidoc-page',
            :syntax => :asciidoc,
            :extension => '.html',
            :matcher => verify
        },
        {
            :page => 'asciidoctor_with_front_matter.ad',
            :simple_name => 'asciidoctor_with_front_matter',
            :syntax => :asciidoc,
            :extension => '.html',
            :matcher => verify_front_matter
        },
        {
            :page => 'asciidoctor_with_headers.ad',
            :simple_name => 'asciidoctor_with_headers',
            :syntax => :asciidoc,
            :extension => '.html',
            :matcher => verify_headers
        },
        {
            :page => 'asciidoc_with_attributes.ad',
            :simple_name => 'asciidoc_with_attributes',
            :syntax => :asciidoc,
            :extension => '.html',
            :matcher => verify_attributes
        }
    ]


describe Awestruct::Handlers::AsciidoctorHandler do
  def additional_config_page
    { :name => 'Awestruct', :test => 10, :layout => 'empty-layout' }
  end

  it_should_behave_like 'a handler', theories
end
