
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/coffeescript_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::CoffeescriptHandler do

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
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "coffeescript-page.coffee" ) )
    coffeescript_handler = Awestruct::Handlers::CoffeescriptHandler.new( @site, file_handler )

    coffeescript_handler.simple_name.should == 'coffeescript-page' 
  end
  
  it "should successfully render an org-mode page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "coffeescript-page.coffee" ) )
    coffeescript_handler = Awestruct::Handlers::CoffeescriptHandler.new( @site, file_handler )

    rendered = coffeescript_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ /function\(\)/
    rendered.should =~ /call\(this\)/
  end

end
