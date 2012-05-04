
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/markdown_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::MarkdownHandler do

  before :all do
    @site = OpenCascade.new :encoding=>false, :dir=>Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' )
  end

  def handler_file(path)
    "#{@site.dir}/#{path}"
  end

  def create_context
    OpenCascade.new :site=>@site
  end

  it "should provide a simple name for the page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "markdown-page.md" ) )
    markdown_handler = Awestruct::Handlers::MarkdownHandler.new( @site, file_handler )

    markdown_handler.simple_name.should == 'markdown-page' 
  end
  
  it "should successfully render a HAML page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "markdown-page.md" ) )
    markdown_handler = Awestruct::Handlers::MarkdownHandler.new( @site, file_handler )

    rendered = markdown_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>This is a Markdown page</h1>) 
  end

end
