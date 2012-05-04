
require 'awestruct/config'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/asciidoc_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::AsciidocHandler do

  before :all do
    dir = Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' ) 

    @site = OpenCascade.new :encoding=>false, 
                            :dir=>dir,
                            :config=>Awestruct::Config.new( dir )
  end

  def handler_file(path)
    "#{@site.config.dir}/#{path}"
  end

  def create_context
    OpenCascade.new :site=>@site
  end

  it "should provide a simple name for the page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.adoc" ) )
    asciidoc_handler = Awestruct::Handlers::AsciidocHandler.new( @site, file_handler )

    asciidoc_handler.simple_name.should == 'asciidoc-page' 
  end
  
=begin
  it "should successfully render an ASCIIDoc page" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.adoc" ) )
    asciidoc_handler = Awestruct::Handlers::AsciidocHandler.new( @site, file_handler )

    rendered = asciidoc_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.should =~ %r(<h1>This is a Markdown page</h1>) 
  end
=end

end
