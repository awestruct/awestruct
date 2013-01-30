require 'spec_helper'

verify = lambda { |output|
  output.should =~ %r(<h1>This is a Markdown page</h1>)
}

theories =
  [
    {
      :page => "markdown-page.md",
      :simple_name => "markdown-page",
      :syntax => :markdown,
      :extension => '.html',
      :matcher => verify
    },
    {
      :page => "markdown-page.markdown",
      :simple_name => "markdown-page",
      :syntax => :markdown,
      :extension => '.html',
      :matcher => verify
    },
    {
      :page => "markdown-page.mkd",
      :simple_name => "markdown-page",
      :syntax => :markdown,
      :extension => '.html',
      :matcher => verify
    }
  ]

describe Awestruct::Handlers::TiltHandler.to_s + "-Markdown" do
  
  it_should_behave_like "a handler", theories

end