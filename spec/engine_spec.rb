
require 'awestruct/engine'

require 'hashery/open_cascade'

describe Awestruct::Engine do

  it "should be able to load site.yml with the correct profile" do
    config = Awestruct::Config.new( File.dirname(__FILE__) + '/test-data/engine' )

    engine = Awestruct::Engine.new(config)
    engine.load_site_yaml( 'development' )
    engine.site.cook.should == 'microwave'
    engine.site.title.should == 'Awestruction!'

    engine = Awestruct::Engine.new(config)
    engine.load_site_yaml( 'production' )
    engine.site.cook.should == 'oven'
    engine.site.title.should == 'Awestruction!'
  end

  it "should be able to load arbitrary _config/*.yml files" do
    config = Awestruct::Config.new( File.dirname(__FILE__) + '/test-data/engine' )

    engine = Awestruct::Engine.new(config)
    engine.load_yaml( File.join( config.dir,  '_config/arbitrary.yml' ) )
    engine.site.arbitrary.name.should == 'randomness'
  end

  it "should be able to load all arbitary yamls" do
    config = Awestruct::Config.new( File.dirname(__FILE__) + '/test-data/engine' )

    engine = Awestruct::Engine.new(config)
    engine.load_yamls

    engine.site.arbitrary.name.should == 'randomness'
    engine.site.other.tags.should == [ 'a', 'b', 'c' ]
  end

end
