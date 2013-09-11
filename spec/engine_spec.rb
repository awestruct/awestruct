require 'awestruct/cli/options'
require 'awestruct/engine'

require 'hashery/open_cascade'

describe Awestruct::Engine do

  it "should be able to load default-site.yml" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_default_site_yaml

    engine.site.asciidoctor.backend.should == 'html5'
    engine.site.asciidoctor.safe.should == 1
    engine.site.asciidoctor.attributes['imagesdir'].should == '/images'
    engine.site.profiles.development.show_drafts.should == true
  end

  it "should be able to override default with site" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_default_site_yaml
    engine.load_user_site_yaml( 'development' )

    engine.site.asciidoctor.safe.should == 0
    engine.site.asciidoctor.eruby.should == 'erubis'
    engine.site.asciidoctor.attributes['imagesdir'].should == '/assets/images'
    engine.site.asciidoctor.attributes['idprefix'].should == ''
    engine.site.show_drafts.should == false
  end

  it "should be able to load site.yml with the correct profile" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_default_site_yaml
    engine.load_user_site_yaml( 'development' )
    engine.site.cook.should == 'microwave'
    engine.site.title.should == 'Awestruction!'
    engine.site.show_drafts.should == false

    engine = Awestruct::Engine.new(config)
    engine.load_default_site_yaml
    engine.load_user_site_yaml( 'production' )
    engine.site.cook.should == 'oven'
    engine.site.title.should == 'Awestruction!'
    engine.site.asciidoctor.eruby.should == 'erb'
    engine.site.asciidoctor.attributes['imagesdir'].should == '/img'
    engine.site.show_drafts.should == true
  end

  it "should be able to load arbitrary _config/*.yml files" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_yaml( File.join( config.dir,  '_config/arbitrary.yml' ) )
    engine.site.arbitrary.name.should == 'randomness'
  end

  it "should be able to load all arbitary yamls" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_yamls

    engine.site.arbitrary.name.should == 'randomness'
    engine.site.other.tags.should == [ 'a', 'b', 'c' ]
  end

  it "should exclude line comments and minify in compass by default in production mode" do
    compass = compass_config
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.load_user_site_yaml( 'production' )
    Compass.stub(:configuration).and_return(compass)
    compass.should_receive(:line_comments=).with(false)
    compass.stub(:line_comments).and_return(false)
    compass.should_receive(:output_style=).with(:compressed)
    compass.stub(:output_style).and_return(:compressed)
    compass.stub(:http_path=).with(nil)
    compass.stub(:relative_assets=).with(false)
    engine.configure_compass
    engine.site.sass.line_numbers.should == false
    engine.site.sass.style.should == :compressed
    engine.site.scss.line_numbers.should == false
    engine.site.scss.style.should == :compressed
  end

  it "should include line comments in compass by default in development mode" do
    compass = compass_config
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.load_user_site_yaml( 'development' )
    Compass.stub(:configuration).and_return(compass)
    compass.should_receive(:line_comments=).with(true)
    compass.stub(:line_comments).and_return(true)
    compass.should_receive(:output_style=).with(:expanded)
    compass.stub(:output_style).and_return(:expanded)
    compass.stub(:http_path=).with(nil)
    compass.stub(:relative_assets=).with(false)
    engine.configure_compass
    engine.site.sass.line_numbers.should == true
    engine.site.sass.style.should == :expanded
    engine.site.scss.line_numbers.should == true
    engine.site.scss.style.should == :expanded
  end

  it "wip should accept site.compass_line_comments and site.compass_output_style to configure behavior" do
    compass = compass_config
    opts = Awestruct::CLI::Options.new
    opts.source_dir = File.dirname(__FILE__) + '/test-data/engine'
    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.load_user_site_yaml( 'staging' )
    Compass.stub(:configuration).and_return(compass)
    compass.should_receive(:line_comments=).with(false)
    compass.stub(:line_comments).and_return(false)
    compass.should_receive(:output_style=).with(:compact)
    compass.stub(:output_style).and_return(:compact)
    compass.stub(:http_path=).with(nil)
    compass.stub(:relative_assets=).with(false)
    engine.configure_compass
    engine.site.sass.line_numbers.should == false
    engine.site.sass.style.should == :compact
    engine.site.scss.line_numbers.should == false
    engine.site.scss.style.should == :compact
  end

end

def compass_config
  config = mock
  config.stub(:project_type=)
  config.stub(:project_path=)
  config.stub(:sass_dir=)
  config.stub(:css_dir=)
  config.stub(:javascripts_dir=)
  config.stub(:images_dir=)
  config.stub(:fonts_dir=)
  config
end
