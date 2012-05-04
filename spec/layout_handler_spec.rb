
require 'awestruct/handlers/layout_handler'
require 'awestruct/handlers/string_handler'
require 'awestruct/engine'
require 'awestruct/handler_chains'
require 'awestruct/site'
require 'awestruct/page'
require 'awestruct/page_loader'

require 'hashery/open_cascade'
require 'ostruct'

describe Awestruct::Handlers::LayoutHandler do


  before :all do
    @config = OpenCascade.new( :dir=>Pathname.new( File.dirname(__FILE__) + '/test-data/handlers' ) )
    @engine = Awestruct::Engine.new
    @site = Awestruct::Site.new( @engine, @config )
    layout_loader = Awestruct::PageLoader.new( @site, :layouts )
    layout = layout_loader.load_page( File.join( @config.dir, 'haml-layout.html.haml' ) )
    layout.class.should == Awestruct::Page
    layout.should_not be_nil

    @site.layouts << layout

    layout = layout_loader.load_page( File.join( @config.dir, 'haml-layout-two.html.haml' ) )
    layout.class.should == Awestruct::Page
    layout.should_not be_nil

    @site.layouts << layout
  end

  it "should be able to find layouts by simple name" do
    layout = @site.layouts.find_matching( 'haml-layout', '.html' )
    layout.class.should == Awestruct::Page
  end

  it "should apply the layout to its delegate's content" do
    primary_handler = Awestruct::Handlers::StringHandler.new( @site, "this is the content" )
    layout_handler = Awestruct::Handlers::LayoutHandler.new( @site, primary_handler )

    page = Awestruct::Page.new( @site, layout_handler )

    context = page.create_context
    context.page.layout = 'haml-layout'

    @site.layouts.find_matching( 'haml-layout', '.html' ).should_not be_nil
    rendered = layout_handler.rendered_content( context )
    
  end

  it "should recursively apply the layout to its delegate's content" do
    primary_handler = Awestruct::Handlers::StringHandler.new( @site, "this is the content" )
    layout_handler = Awestruct::Handlers::LayoutHandler.new( @site, primary_handler )

    page = Awestruct::Page.new( @site, layout_handler )
    page.layout = 'haml-layout-two'

    context = page.create_context

    @site.layouts.find_matching('haml-layout', '.html').should_not be_nil
    rendered = layout_handler.rendered_content( context )

    haml_index = ( rendered =~ %r(This is a haml layout) )
    awestruct_index = ( rendered =~ %r(Welcome to Awestruct) )
    content_index = ( rendered =~ %r(this is the content) )

    haml_index.should > 0
    awestruct_index.should > 0
    content_index.should > 0 

    haml_index.should < awestruct_index
    awestruct_index.should < content_index
  end

end
