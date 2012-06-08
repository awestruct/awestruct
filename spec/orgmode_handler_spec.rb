
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/orgmode_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::OrgmodeHandler do

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
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "orgmode-page.org" ) )
    orgmode_handler = Awestruct::Handlers::OrgmodeHandler.new( @site, file_handler )

    orgmode_handler.simple_name.should == 'orgmode-page' 
  end
  
  it "should successfully render an org-mode page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "orgmode-page.org" ) )
    orgmode_handler = Awestruct::Handlers::OrgmodeHandler.new( @site, file_handler )

    rendered = orgmode_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1 class="title">Fruit</h1>)
    rendered.should =~ %r(<p>Apples are red</p>)
  end

end
