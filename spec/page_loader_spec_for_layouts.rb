require 'awestruct/engine'
require 'awestruct/site'
require 'awestruct/page_loader'
require 'awestruct/config'

describe Awestruct::PageLoader do

  before :each do
    @opts = Awestruct::CLI::Options.new
    @opts.source_dir = File.dirname(__FILE__) + '/test-data/page-loader'
    @config = Awestruct::Config.new( @opts )
    @engine = Awestruct::Engine.new
    @engine.pipeline.handler_chains << :defaults
    @site   = Awestruct::Site.new( @engine, @config )
    @loader = Awestruct::PageLoader.new( @site, :layouts )
  end

  it "should be able to load a site layout" do
    page = @loader.load_page( File.join( @config.dir, "_layouts", "layout-one.md" ) )
    page.should_not be_nil
    page.handler.to_chain.collect{|e| e.class}.should be_include Awestruct::Handlers::TiltHandler
    page.relative_source_path.to_s.should == "/_layouts/layout-one.md" 
  end

  it "should be able to load all site layouts" do
    @loader.load_all
    @site.layouts.size.should == 2

    @site.layouts.sort!{|l,r| l.relative_source_path <=> r.relative_source_path }

    @site.layouts[0].relative_source_path.should == '/_layouts/layout-one.md'
    @site.layouts[0].output_path.should          == '/_layouts/layout-one.html'

    @site.layouts[1].relative_source_path.should == '/_layouts/layout-two.html.haml'
    @site.layouts[1].output_path.should          == '/_layouts/layout-two.html'
  end

end
