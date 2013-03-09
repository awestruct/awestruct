require 'spec_helper'
require 'rspec/matchers.rb'

verify = lambda { |output|
  output.gsub(/(^\s*\n|^\s*)/, '').should =~ %r(<div id="preamble">
<div class="sectionbody">
<div class="paragraph">
<p>This is <strong>AsciiDoc</strong> in Awestruct.</p>
</div>
</div>
</div>)
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
  page.tags.should be_a_kind_of(Array)
  page.tags.should == %w(a b c)
  page.date.should be_a_kind_of(Date)
  output.should =~ %r(This is <strong>AsciiDoc</strong> in Awestruct.)
  output.should =~ %r(#{Awestruct::VERSION})
}

theories =
  [
    {
      :page => "asciidoc-page.ad",
      :simple_name => "asciidoc-page",
      :syntax => :asciidoc,
      :extension => '.html',
      :matcher => verify
    },
    {
      :page => "asciidoc-page.adoc",
      :simple_name => "asciidoc-page",
      :syntax => :asciidoc,
      :extension => '.html',
      :matcher => verify
    },
    {
      :page => "asciidoc-page.asciidoc",
      :simple_name => "asciidoc-page",
      :syntax => :asciidoc,
      :extension => '.html',
      :matcher => verify
    },
    {
      :page => "asciidoctor_with_front_matter.ad",
      :simple_name => "asciidoctor_with_front_matter",
      :syntax => :asciidoc,
      :extension => '.html' ,
      :matcher => verify_front_matter
    },
    {
      :page => "asciidoctor_with_headers.ad",
      :simple_name => "asciidoctor_with_headers",
      :syntax => :asciidoc,
      :extension => '.html',
      :matcher => verify_headers
    }
  ]

describe Awestruct::Handlers::AsciidoctorHandler do
  let(:additional_config_page) { {:name => 'Awestruct', :test => 10} }
  it_should_behave_like "a handler", theories

end
