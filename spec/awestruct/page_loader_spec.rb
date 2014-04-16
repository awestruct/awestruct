require 'awestruct/engine'
require 'awestruct/site'
require 'awestruct/page_loader'
require 'awestruct/config'

describe Awestruct::PageLoader do

  before :each do
    @opts = Awestruct::CLI::Options.new
    @opts.source_dir = test_data_dir 'page-loader'
    @config = Awestruct::Config.new( @opts )
    @engine = Awestruct::Engine.new
    @engine.pipeline.handler_chains << :defaults
    @site   = Awestruct::Site.new( @engine, @config )
    @loader = Awestruct::PageLoader.new( @site, :pages )
  end

  it "should be able to load a site page" do
    page = @loader.load_page( File.join( @config.dir, "page-one.md" ) )
    page.should_not be_nil
    page.handler.to_chain.collect{|e| e.class}.should be_include Awestruct::Handlers::TiltHandler
    page.relative_source_path.to_s.should == "/page-one.md" 
  end

  it "should be able to load an out-of-site page" do
    page = @loader.load_page( File.join( @config.dir, '../out-of-site', "page-three.html.haml" ) )
    page.should_not be_nil
    page.handler.to_chain.collect{|e| e.class }.should be_include Awestruct::Handlers::TiltHandler
    page.relative_source_path.should be_nil
  end

  it "should be able to load all non-draft site pages" do
    @loader.load_all
    @site.pages.size.should == 2

    @site.pages.sort!{|l,r| l.relative_source_path <=> r.relative_source_path }

    @site.pages[0].relative_source_path.should == '/page-one.md'
    @site.pages[0].output_path.should          == '/page-one.html'

    @site.pages[1].relative_source_path.should == '/page-two.html.haml'
    @site.pages[1].output_path.should          == '/page-two.html'
  end

  it "should be able to load all site pages (even drafts) if show_drafts is true" do
    @site.show_drafts = true
    @loader.load_all
    @site.pages.size.should == 3

    @site.pages.sort!{|l,r| l.relative_source_path <=> r.relative_source_path }

    @site.pages[0].relative_source_path.should == '/page-draft.md'
    @site.pages[0].output_path.should          == '/page-draft.html'

    @site.pages[1].relative_source_path.should == '/page-one.md'
    @site.pages[1].output_path.should          == '/page-one.html'

    @site.pages[2].relative_source_path.should == '/page-two.html.haml'
    @site.pages[2].output_path.should          == '/page-two.html'

  end

  context 'with layouts' do
    before :each do
      @opts = Awestruct::CLI::Options.new
      @opts.source_dir = test_data_dir 'page-loader' 
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

end
