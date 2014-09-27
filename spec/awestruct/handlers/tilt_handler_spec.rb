require 'logger'
require 'awestruct/config'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/tilt_handler'

require 'hashery'
require 'tilt/template'

module Tilt
  class BogusTemplate < Template
    self.default_mime_type = 'text/html'

    def self.engine_initialized?
      defined? ::Bogus::Document
    end

    def initialize_engine
      require_template_library 'fake-gem-name'
    end

    def evaluate(scope, locals, &block)
      @output ||= "bogus, bogus, bogus"
    end

    def allows_script?
      false
    end
  end
end


describe Awestruct::Handlers::TiltHandler do

  before do
    dir = Pathname.new( test_data_dir 'handlers' )
    opts = Awestruct::CLI::Options.new
    opts.source_dir = dir

    @site = Hashery::OpenCascade[ { :encoding=>false, :dir=>dir, :config=>Awestruct::Config.new( opts ) } ]
  end

  def handler_file(path)
    "#{@site.config.dir}/#{path}"
  end

  def create_context
    Hashery::OpenCascade[ { :site=>@site, page: {:source_path => '', :output_path => ''} } ]
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
    @site.asciidoctor.property = 'test'
    @site.asciidoc.property = 'test1'

    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.asciidoc" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.options[:property].should == 'test1'
  end

  it "should handle pages with no relative_source_path" do
    ## force relative_source_path.nil
    @site.dir = Pathname.new( test_data_dir 'handlers/outside_relative' )
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "asciidoc-page.asciidoc" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.relative_source_path.should be_nil 
    handler.simple_name.should eql 'asciidoc-page'
    handler.content_syntax.should eql :asciidoc
    handler.output_extension.should eql '.html'
    handler.input_extension.should eql '.asciidoc'
    handler.output_filename.should eql 'asciidoc-page.html'
  end

  it "should handle non extension dots in source name" do
    @site.dir = Pathname.new( test_data_dir 'handlers/outside_relative' )
    file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "warp-1.0.0.Alpha2.textile" ) )
    handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )

    handler.relative_source_path.should be_nil
    handler.simple_name.should eql 'warp-1.0.0.Alpha2'
    handler.content_syntax.should eql :textile
    handler.output_extension.should eql '.html'
    handler.input_extension.should eql '.textile'
    handler.output_filename.should eql 'warp-1.0.0.Alpha2.html'

  end

  context 'when loading an engine not installed' do
    specify 'should not throw exceptions; instead have the error in the rendered output' do
      # setup
      Awestruct::Engine.instance.config.verbose = true
      Tilt::register Tilt::BogusTemplate, '.bogus',
      log = StringIO.new
      $LOG = Logger.new(log)
      $LOG.level = Logger::DEBUG
      @site.dir = Pathname.new( test_data_dir 'handlers' ) 
      path = handler_file( "hello.bogus" )
      expect(Awestruct::Handlers::TiltMatcher.new().match(path)).to be_false
      expect(log.string).to include('Copying')

      # we don't even want to process a file if we cannot load its Tilt template
      #file_handler = Awestruct::Handlers::FileHandler.new( @site, path )
      #handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )
      #content = handler.rendered_content(create_context)

      #expect(content).to_not eql ('bogus, bogus, bogus')
      #expect(content).to include('load', 'fake-gem-name')
    end
  end

  context 'when rendering a file with an error' do
    specify 'should not stop processing, but render the error as the file' do
      # setup
      log = StringIO.new
      $LOG = Logger.new(log)
      $LOG.level = Logger::DEBUG
      @site.dir = Pathname.new( test_data_dir 'handlers' )
      file_handler = Awestruct::Handlers::FileHandler.new( @site, handler_file( "haml-error.html.haml" ) )
      handler = Awestruct::Handlers::TiltHandler.new( @site, file_handler )
      content = handler.rendered_content(create_context)

      expect(content).to_not be_empty
      expect(content).to include('Illegal', 'nesting', 'Line', '2')
    end
  end

end
