require 'spec_helper'

verify = lambda { |output|
  include NokogiriMatchers
  output.should have_tag('h1')
  # TODO: This is the next phase
  #output.should have_tag('h1') do
  #  with_text 'This is a Markdown page'
  #end
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
