
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/erb_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::ErbHandler do

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
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "erb-page.html.erb" ) )
    erb_handler = Awestruct::Handlers::ErbHandler.new( @site, file_handler )

    erb_handler.simple_name.should == 'erb-page' 
  end
  
  it "should successfully render an ERB page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "erb-page.html.erb" ) )
    erb_handler = Awestruct::Handlers::ErbHandler.new( @site, file_handler )

    rendered = erb_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>This is an ERB page</h1>) 
    rendered.should =~ %r(<h2>The fruit of the day is: apples</h2>) 
  end

end
