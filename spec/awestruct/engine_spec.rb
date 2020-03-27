require 'awestruct/cli/options'
require 'awestruct/engine'
require 'logger'

require 'hashery/open_cascade'

describe Awestruct::Engine do

  it "should be able to load default-site.yml" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine' 
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
    opts.source_dir = test_data_dir 'engine' 
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
    opts.source_dir = test_data_dir 'engine' 
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

  it "should be able to handle UTF-8 in site.yml" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine' 
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_default_site_yaml
    engine.load_user_site_yaml( 'development' )
    engine.site.intl_name.should == "Intern\u00e9\u0161nl"
  end

  it "should be able to handle erb in site.yaml" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine-yaml'
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_default_site_yaml
    engine.load_user_site_yaml( 'development' )
    engine.site.date.should be_a Date
    engine.site.date.iso8601.should eql '2015-04-13'
  end


  it "should be able to load arbitrary _config/*.yml files" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine' 
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_yaml( File.join( config.dir,  '_config/arbitrary.yml' ) )
    engine.site.arbitrary.name.should == 'randomness'
  end

  it "should be able to load all arbitary yamls" do
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine' 
    config = Awestruct::Config.new( opts )

    engine = Awestruct::Engine.new(config)
    engine.load_yamls

    engine.site.arbitrary.name.should == 'randomness'
    engine.site.other.tags.should == [ 'a', 'b', 'c' ]
  end

  it "should exclude line comments and minify in compass by default in production mode" do
    require 'compass'
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine'

    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.load_user_site_yaml( 'production' )

    engine.configure_compass

    expect( Compass.configuration.line_comments ).to eq false
    expect( Compass.configuration.output_style ).to eq :compressed
    expect( Compass.configuration.asset_host.call("ignored_by_lambda")).to eq "http://localhost:4242"
    expect( Compass.configuration.relative_assets ).to eq false 
  end

  it "should include line comments in compass by default in development mode" do
    require 'compass'
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine' 
    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.load_user_site_yaml( 'development' )
    engine.configure_compass

    expect( Compass.configuration.line_comments ).to eq true
    expect( Compass.configuration.output_style ).to eq :expanded
  end

  it "should cleanly generate page output, using threads" do
    output_dir = Dir.mktmpdir 'engine-generate-no-errors'

    begin
      Logging.init :trace, :debug, :verbose, :info, :warn, :error, :fatal
      $LOG = Logging.logger.new 'awestruct'
      $LOG.add_appenders(
          Logging.appenders.string_io({level: :info, layout: Logging.layouts.pattern(pattern: "%m\n"),
                                       color_scheme: :default})
      )
      $LOG.level = :debug

      opts = Awestruct::CLI::Options.new
      opts.source_dir = test_data_dir 'engine-generate-no-errors'
      opts.output_dir = output_dir
      config = Awestruct::Config.new( opts )
      engine = Awestruct::Engine.new(config)
      begin
        engine.run('development', 'http://localhost:4242', 'http://localhost:4242')
      rescue SystemExit => e
        e.status.should eql 0
      end
    ensure
      FileUtils.remove_entry_secure output_dir
    end
  end

  it "should cleanly generate page output, using processes" do
    output_dir = Dir.mktmpdir 'engine-generate-no-errors'

    begin
      Logging.init :trace, :debug, :verbose, :info, :warn, :error, :fatal
      $LOG = Logging.logger.new 'awestruct'
      $LOG.add_appenders(
          Logging.appenders.string_io({level: :info, layout: Logging.layouts.pattern(pattern: "%m\n"),
                                    color_scheme: :default})
      )
      $LOG.level = :debug

      opts = Awestruct::CLI::Options.new
      opts.source_dir = test_data_dir 'engine-generate-no-errors'
      opts.output_dir = output_dir
      config = Awestruct::Config.new( opts )
      engine = Awestruct::Engine.new(config)
      engine.site.generation = [:in_processes => 2]
      begin
        engine.run('development', 'http://localhost:4242', 'http://localhost:4242')
      rescue SystemExit => e
        e.status.should eql 0
      end
    ensure
      FileUtils.remove_entry_secure output_dir
    end
  end

  it "should exit unsuccessfully if generate page output fails, using threads" do
    output_dir = Dir.mktmpdir 'engine-generate-with-errors'

    begin
      Logging.init :trace, :debug, :verbose, :info, :warn, :error, :fatal
      $LOG = Logging.logger.new 'awestruct'
      $LOG.add_appenders(
          Logging.appenders.string_io({level: :info, layout: Logging.layouts.pattern(pattern: "%m\n"),
                                       color_scheme: :default})
      )
      $LOG.level = :debug

      opts = Awestruct::CLI::Options.new
      opts.source_dir = test_data_dir 'engine-generate-with-errors'
      opts.output_dir = output_dir
      config = Awestruct::Config.new( opts )
      engine = Awestruct::Engine.new(config)
      begin
        engine.run('development', 'http://localhost:4242', 'http://localhost:4242')
        fail('Expected generation error')
      rescue SystemExit => e
        e.status.should eql Awestruct::ExceptionHelper::EXITCODES[:generation_error]
      end
    ensure
      FileUtils.remove_entry_secure output_dir, true
    end
  end

  it "should exit unsuccessfully if page syntax is invalid, using threads" do
    output_dir = Dir.mktmpdir 'engine-generate-with-errors'

    begin
      Logging.init :trace, :debug, :verbose, :info, :warn, :error, :fatal
      $LOG = Logging.logger.new 'awestruct'
      $LOG.add_appenders(
          Logging.appenders.string_io({level: :info, layout: Logging.layouts.pattern(pattern: "%m\n"),
                                       color_scheme: :default})
      )
      $LOG.level = :debug

      opts = Awestruct::CLI::Options.new
      opts.source_dir = test_data_dir 'engine-generate-syntax-errors'
      opts.output_dir = output_dir
      config = Awestruct::Config.new( opts )
      engine = Awestruct::Engine.new(config)
      begin
        engine.run('development', 'http://localhost:4242', 'http://localhost:4242')
        fail('Expected generation error')
      rescue SystemExit => e
        e.status.should eql Awestruct::ExceptionHelper::EXITCODES[:generation_error]
      end
    ensure
      FileUtils.remove_entry_secure output_dir, true
    end
  end

  it "should exit unsuccessfully if generate page output fails, using processes" do
    output_dir = Dir.mktmpdir 'engine-generate-with-errors'

    begin
      Logging.init :trace, :debug, :verbose, :info, :warn, :error, :fatal
      $LOG = Logging.logger.new 'awestruct'
      $LOG.add_appenders(
          Logging.appenders.string_io({level: :info, layout: Logging.layouts.pattern(pattern: "%m\n"),
                                       color_scheme: :default})
      )
      $LOG.level = :debug

      opts = Awestruct::CLI::Options.new
      opts.source_dir = test_data_dir 'engine-generate-with-errors'
      opts.output_dir = output_dir
      config = Awestruct::Config.new( opts )
      engine = Awestruct::Engine.new(config)
      engine.site.generation = [:in_processes => 2]
      begin
        engine.run('development', 'http://localhost:4242', 'http://localhost:4242')
        fail('Expected generation error')
      rescue SystemExit => e
        e.status.should eql Awestruct::ExceptionHelper::EXITCODES[:generation_error]
      end
    ensure
      FileUtils.remove_entry_secure output_dir, true
    end
  end

  it "should accept site.compass_line_comments and site.compass_output_style to configure behavior" do
    require 'compass'
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine' 
    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.load_user_site_yaml( 'staging' )
    engine.configure_compass

    expect( Compass.configuration.line_comments ).to eq false
    expect( Compass.configuration.output_style ).to eq :compact
  end

  it "with a _config/compass.rb file, it should override defaults" do
    require 'compass'
    opts = Awestruct::CLI::Options.new
    opts.source_dir = test_data_dir 'engine-compass' 
    config = Awestruct::Config.new( opts )
    engine = Awestruct::Engine.new(config)
    engine.configure_compass

    expect( Compass.configuration.line_comments ).to eq false
    expect( Compass.configuration.output_style ).to eq :compressed
    expect( Compass.configuration.disable_warnings ).to eq true
    expect( Compass.configuration.fonts_dir ).to eq 'my-fonts'
  end

end

