require 'hashery/open_cascade'
require 'awestruct/page'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/javascript_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::JavascriptHandler do

  before :all do
    @page = Awestruct::Page.new( site, Awestruct::Handlers::JavascriptHandler::CHAIN.create( site, handler_file("javascript-page.js") ) )
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

  it "should interpolate Javascript files" do
    @page.content.should =~ %r(var crunchy = "bacon")
  end

end

