
require 'awestruct/page'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/haml_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::HamlHandler do

  before :all do
    @page = Awestruct::Page.new( site, 
                                 Awestruct::Handlers::HamlHandler::CHAIN.create( site, 
                                                                                 handler_file("haml-with-variables.html.haml") ) )
    @page.prepare!
  end

  def site
    @site ||= OpenCascade.new( :encoding=>false, 
                               :dir=>Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' ), 
                               :crunchy => "bacon", 
                               :config => { :dir => 'foo' } )
  end

  def handler_file(path)
    Pathname.new( File.dirname( __FILE__ ) + "/test-data/handlers/#{path}" )
  end

  def create_context
    OpenCascade.new :site=>site
  end

  it "should provide a simple name for the page" do
    file_handler = Awestruct::Handlers::FileHandler.new( site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( site, file_handler )

    haml_handler.simple_name.should == 'haml-page'
  end
  
  it "should successfully render a HAML page" do
    file_handler = Awestruct::Handlers::FileHandler.new( site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( site, file_handler )

    rendered = haml_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>This is a HAML page</h1>) 
  end

  it "should provide the correct output extension" do
    file_handler = Awestruct::Handlers::FileHandler.new( site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( site, file_handler )

    haml_handler.output_extension.should == '.html'

    file_handler = Awestruct::Handlers::FileHandler.new( site, handler_file( "haml-page.xml.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( site, file_handler )

    haml_handler.output_extension.should == '.xml'
  end

  it "should provide the correct simple name" do
    file_handler = Awestruct::Handlers::FileHandler.new( site, handler_file( "haml-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( site, file_handler )

    haml_handler.simple_name.should == 'haml-page'
  end

  it "should interpolate site variables" do
    @page.content.should =~ %r(<h1>bacon</h1>)
  end

  it "should support embedded markdown" do
    file_handler = Awestruct::Handlers::FileHandler.new( site, handler_file( "haml-with-markdown-page.html.haml" ) )
    haml_handler = Awestruct::Handlers::HamlHandler.new( site, file_handler )

    rendered = haml_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>Hello From Markdown</h1>) 
  end
end
