require 'hashery/open_cascade'
require 'awestruct/page'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/redirect_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::RedirectHandler do

  before :all do
    @page = Awestruct::Page.new( site, Awestruct::Handlers::RedirectHandler::CHAIN.create( site, handler_file("simple-redirect-page.redirect") ) )
    @page.prepare!
    @interpolated = Awestruct::Page.new( site, Awestruct::Handlers::RedirectHandler::CHAIN.create( site, handler_file("redirect-page.redirect") ) )
    @interpolated.prepare!
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

  it "should emit <meta http-equiv ...>" do
    @page.content.should =~ %r(<head><meta http-equiv="location" content="URL=http://google.com" /></head>)
  end

  it "should interpolate variables" do
    @interpolated.content.should =~ %r(<head><meta http-equiv="location" content="URL=http://bacon.com" /></head>)
  end

end


