require 'awestruct/engine'
require 'awestruct/site'
require 'awestruct/page_loader'
require 'awestruct/config'

describe Awestruct::PageLoader do

  before :each do
    @config = Awestruct::Config.new( File.dirname(__FILE__) + "/test-data/page-loader" )
    @engine = Awestruct::Engine.new
    @engine.pipeline.handler_chains << :defaults
    @site   = Awestruct::Site.new( @engine, @config )
    @loader = Awestruct::PageLoader.new( @site, :pages )
  end

  it "should be able to load a site page" do
    page = @loader.load_page( File.join( @config.dir, "page-one.md" ) )
    page.should_not be_nil
    page.handler.to_chain.collect{|e| e.class}.should be_include Awestruct::Handlers::MarkdownHandler
    page.relative_source_path.to_s.should == "/page-one.md" 
  end

  it "should be able to load an out-of-site page" do
    page = @loader.load_page( File.join( @config.dir, '../out-of-site', "page-three.html.haml" ) )
    page.should_not be_nil
    page.handler.to_chain.collect{|e| e.class}.should be_include Awestruct::Handlers::HamlHandler
    page.relative_source_path.should be_nil
  end

  it "should be able to load all site pages" do
    @loader.load_all
    @site.pages.size.should == 2

    @site.pages.sort!{|l,r| l.relative_source_path <=> r.relative_source_path }

    @site.pages[0].relative_source_path.should == '/page-one.md'
    @site.pages[0].output_path.should          == '/page-one.html'

    @site.pages[1].relative_source_path.should == '/page-two.html.haml'
    @site.pages[1].output_path.should          == '/page-two.html'
  end

end
