
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
  
  it "should render an AsciiDoc page using Asciidoctor by default" do
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.adoc" ) )
    asciidoc_handler = Awestruct::Handlers::AsciidocHandler.new( @site, file_handler )

    @site.asciidoc[:engine].should == 'asciidoctor'
    @site.asciidoc[:engine_loaded].should == true
    rendered = asciidoc_handler.rendered_content( create_context )
    rendered.should_not be_nil
    rendered.gsub(/(^\s*\n|^\s*)/, '').should =~ %r(<div id="preamble">
<div class="sectionbody">
<div class="paragraph">
<p>This is <strong>AsciiDoc</strong> in Awestruct.</p>
</div>
</div>
</div>) 
  end

=begin
  # TODO to run this test in CI requires setting up asciidoc
  it "should render an AsciiDoc page using system asciidoc command when engine is system" do
    @site.asciidoc[:engine] = 'system'
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.adoc" ) )
    asciidoc_handler = Awestruct::Handlers::AsciidocHandler.new( @site, file_handler )

    @site.asciidoc[:engine].should == 'system'
    @site.asciidoc[:engine_loaded].should == true
    rendered = asciidoc_handler.rendered_content( create_context )
    puts rendered
    rendered.should_not be_nil
    rendered.should =~ %r(<div id="preamble">
<div class="sectionbody">
<div class="paragraph"><p>This is <strong>AsciiDoc</strong> in Awestruct.</p></div>
</div>
</div>) 
  end
=end

end
