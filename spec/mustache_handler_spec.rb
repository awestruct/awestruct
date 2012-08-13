
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/mustache_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::MustacheHandler do

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
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "mustache-page.html.mustache" ) )
    mustache_handler = Awestruct::Handlers::MustacheHandler.new( @site, file_handler )

    mustache_handler.simple_name.should == 'mustache-page'
  end
  
  it "should successfully render a mustache page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "mustache-page.html.mustache" ) )
    mustache_handler = Awestruct::Handlers::MustacheHandler.new( @site, file_handler )

    rendered = mustache_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>This is a Mustache page</h1>) 
  end

  it "should provide the correct output extension" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "mustache-page.html.mustache" ) )
    mustache_handler = Awestruct::Handlers::MustacheHandler.new( @site, file_handler )

    mustache_handler.output_extension.should == '.html'

    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "mustache-page.xml.mustache" ) )
    mustache_handler = Awestruct::Handlers::MustacheHandler.new( @site, file_handler )

    mustache_handler.output_extension.should == '.xml'
  end

  it "should provide the correct simple name" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "mustache-page.html.mustache" ) )
    mustache_handler = Awestruct::Handlers::MustacheHandler.new( @site, file_handler )

    mustache_handler.simple_name.should == 'mustache-page'
  end

end
