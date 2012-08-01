require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/javascript_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::JavascriptHandler do

  before :all do
    @site = OpenCascade.new :encoding=>false, :dir=>Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' ), :foo => "bacon"
  end

  def handler_file(path)
    File.dirname( __FILE__ ) + "/test-data/handlers/#{path}"
  end

  def create_context
    OpenCascade.new :site=>@site
  end

  it "should render a Javascript file" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "javascript-page.js" ) )
    javascript_handler = Awestruct::Handlers::JavascriptHandler.new( @site, file_handler )

    rendered = javascript_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(var crunchy = "bacon")

  end

  it "should interpolate Javascript files" do
    Awestruct::Handlers::JavascriptHandler::CHAIN.handler_classes.include?( Awestruct::Handlers::InterpolationHandler ).should be_true
  end

end

