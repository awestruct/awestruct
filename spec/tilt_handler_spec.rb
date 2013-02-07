
require 'awestruct/config'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/tilt_handler'

require 'hashery/open_cascade'

describe Awestruct::Handlers::TiltHandler do

  before do
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

  it "should provide default configuration options from site based on output_extension" do
    @site.asciidoc.property = 'test'

    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.asciidoc" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.options[:property].should == 'test'
  end

  it "should provide default configuration options from site based on engine" do
    @site.asciidoctor.property = 'test'

    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.asciidoc" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.options[:property].should == 'test'
  end

  it "should override engine configuration options over output_extension" do
    @site.asciidoc.property = 'test'
    @site.asciidoctor.property = 'test1'

    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.asciidoc" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.options[:property].should == 'test1'
  end

  it "should handle pages with no relative_source_path" do
    ## force relative_source_path.nil
    @site.dir = Pathname.new( File.dirname(__FILE__) + '/test-data/handlers/outside_relative' )  
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.asciidoc" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.relative_source_path.should be_nil
    handler.simple_name.should == 'asciidoc-page'
    handler.content_syntax.should == :asciidoc
    handler.output_extension.should == '.html'
    handler.input_extension.should == '.asciidoc'
    handler.output_filename.should == 'asciidoc-page.html'
  end

  it "should handle non extension dots in source name" do
    @site.dir = Pathname.new( File.dirname(__FILE__) + '/test-data/handlers/outside_relative' )  
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "warp-1.0.0.Alpha2.textile" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.relative_source_path.should be_nil
    handler.simple_name.should == 'warp-1.0.0.Alpha2'
    handler.content_syntax.should == :textile
    handler.output_extension.should == '.html'
    handler.input_extension.should == '.textile'
    handler.output_filename.should == 'warp-1.0.0.Alpha2.html'

  end
end
