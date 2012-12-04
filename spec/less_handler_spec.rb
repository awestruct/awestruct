
require 'awestruct/page'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/less_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::LessHandler do

  before :all do
    @site = OpenCascade.new :encoding=>false, :dir=>Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' )
    @page = Awestruct::Page.new( @site, Awestruct::Handlers::LessHandler::CHAIN.create( @site, handler_file( 'less-page.less') ) )
    @page.prepare!
  end

  def handler_file(path)
    "#{@site.dir}/#{path}"
  end

  it "should provide a simple name for the page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( 'less-page.less' ) )
    less_handler = Awestruct::Handlers::LessHandler.new( @site, file_handler )

    less_handler.simple_name.should == 'less-page' 
  end
  
  it "should successfully render a less page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( 'less-page.less' ) )
    less_handler = Awestruct::Handlers::LessHandler.new( @site, file_handler )

    rendered = less_handler.rendered_content( @page.create_context )
    rendered.should_not be_nil
    rendered.should =~ /\.class {\n  width: 2;\n}/
  end

end
