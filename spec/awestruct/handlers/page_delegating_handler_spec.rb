
require 'awestruct/engine'
require 'awestruct/site'
require 'awestruct/page'
require 'awestruct/handlers/page_delegating_handler'
require 'hashery'

describe Awestruct::Handlers::PageDelegatingHandler do

  before :each do
    @config = Hashery::OpenCascade[ { :dir=>Pathname.new( test_data_dir 'handlers' ) } ]
    @engine = Awestruct::Engine.new( @config )
    @site = @engine.site
    layout_loader = Awestruct::PageLoader.new( @site, :layouts )

    layout = layout_loader.load_page( File.join( @config.dir, 'haml-layout.html.haml' ) )
    layout.class.should == Awestruct::Page
    layout.should_not be_nil

    @site.layouts << layout

    layout = layout_loader.load_page( File.join( @config.dir, 'haml-layout-two.html.haml' ) )
    layout.class.should == Awestruct::Page
    layout.should_not be_nil

    @site.layouts << layout

    layout = layout_loader.load_page( File.join( @config.dir, 'outer-layout.html.haml' ) )
    layout.class.should == Awestruct::Page
    layout.should_not be_nil

    @site.layouts << layout
  end

  it "should provide layed-out content for the page's content" do
    inner_page = @engine.load_site_page( "inner-page.html.haml" )

    page = Awestruct::Page.new( @site, Awestruct::Handlers::PageDelegatingHandler.new( @site, inner_page) )
    c = page.content
    c.should =~ %r(<h1>This is a haml layout</h1>\n<h2>This is the inner page\n</h2>\n)
    c.should_not =~ %r(<b>)
  end

  it "should provide for laying out both inner and outer page content" do
    inner_page = @engine.load_site_page( "inner-page.html.haml" )

    page = Awestruct::Page.new( @site,
                                Awestruct::Handlers::LayoutHandler.new( @site,
                                                                        Awestruct::Handlers::PageDelegatingHandler.new( @site,
                                                                                                                        inner_page) ) )
    page.layout = 'outer-layout'
    page.output_path = '/outer-page.html'

    c = page.content
    c.should =~ %r(<h1>This is a haml layout</h1>\n<h2>This is the inner page\n</h2>\n)
    c.should_not =~ %r(<b>)

    c = page.rendered_content
    c.should =~ %r(<h1>This is a haml layout</h1>\n<h2>This is the inner page\n</h2>\n)
    c.should =~ %r(<b>)
  end

  it "should provide a simple Page-ctor to delegate" do
    inner_page = @engine.load_site_page( "inner-page.html.haml" )
    page = Awestruct::Page.new( @site, inner_page )
    page.layout= 'outer-layout'

    c = page.content
    c.should =~ %r(<h1>This is a haml layout</h1>\n<h2>This is the inner page\n</h2>\n)
    c.should_not =~ %r(<b>)

    c = page.rendered_content
    c.should =~ %r(<h1>This is a haml layout</h1>\n<h2>This is the inner page\n</h2>\n)
    c.should =~ %r(<b>)
  end

end
