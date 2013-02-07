require 'spec_helper'

verify = lambda { |output|
  output.gsub(/(^\s*\n|^\s*)/, '').should =~ %r(<div id="preamble">
<div class="sectionbody">
<div class="paragraph">
<p>This is <strong>AsciiDoc</strong> in Awestruct.</p>
</div>
</div>
</div>)
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
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-AsciiDoc" do

  it_should_behave_like "a handler", theories

end