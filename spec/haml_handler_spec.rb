
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/haml_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::HamlHandler do

  before :all do
    @site = OpenCascade.new :encoding=>false, :dir=>Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' )
  end

  def handler_file(path)
    File.dirname( __FILE__ ) + "/test-data/handlers/#{path}"
  end

  def create_context
    OpenCascade.new :site=>@site
  end

  it "should provide a simple name for the page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( @site, file_handler )

    haml_handler.simple_name.should == 'haml-page'
  end
  
  it "should successfully render a HAML page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( @site, file_handler )

    rendered = haml_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>This is a HAML page</h1>) 
  end

  it "should provide the correct output extension" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( @site, file_handler )

    haml_handler.output_extension.should == '.html'

    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "haml-page.xml.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( @site, file_handler )

    haml_handler.output_extension.should == '.xml'
  end

  it "should provide the correct simple name" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( @site, file_handler )

    haml_handler.simple_name.should == 'haml-page'
  end

end
