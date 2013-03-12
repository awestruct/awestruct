
require 'awestruct/cli/options'

describe Awestruct::CLI::Options do

  it "should have reasonable defaults" do
    options = Awestruct::CLI::Options.new
    options.generate.should == nil
    options.server.should   == false
    options.deploy.should   == false

    options.port.should      == 4242
    options.bind_addr.should == '0.0.0.0'

    options.auto.should  == false
    options.force.should == false
    options.init.should  == false

    options.framework.should == 'compass'
    options.scaffold.should == true

    options.base_url.should == nil
    options.profile.should  == nil
    options.script.should   == nil
    options.verbose.should  == false
  end

  describe "parsing" do 
    def parse!(*args)
      Awestruct::CLI::Options.parse! args
    end

    it "should parse server-related args" do
      parse!( '-s' ).server.should == true
      parse!( '--server' ).server.should == true

      parse!( '-p', '8180' ).port.should == 8180
      parse!( '--port', '8181' ).port.should == 8181

      parse!( '-b', '1.2.3.4' ).bind_addr.should == '1.2.3.4'
      parse!( '--bind', '5.6.7.8' ).bind_addr.should == '5.6.7.8'

      parse!( '-u', 'http://mysite.com/' ).base_url.should == 'http://mysite.com/' 
      parse!( '--url', 'http://mysite.com/' ).base_url.should == 'http://mysite.com/'
    end

    it "should parse profile-related args" do
      parse!( '-P', 'numberwang' ).profile.should == 'numberwang'
      parse!( '--profile', 'superhans' ).profile.should == 'superhans'
    end

    it "should parse generation-related args" do
      parse!( '-g' ).generate.should == true
      parse!( '--generate' ).generate.should == true
      parse!( '--no-generate' ).generate.should == false

      parse!( '--force' ).force.should == true

      parse!( '-a' ).auto.should == true
      parse!( '--auto' ).auto.should == true
    end

    it "should parse script-related args" do
      pending "Not yet implemented. See issue #248."
      #parse!( '--run', 'puts "hi"' ).script.should == 'puts "hi"'
    end

    it "should turn off generate when doing a --deploy" do
      result = parse!( '--deploy' )
      result.deploy.should be_true
      result.generate.should be_false
    end

    it "should turn off generate when doing a --deploy unless explicitly turned back on" do
      result = parse!( '--deploy', '--generate' )
      result.deploy.should be_true
      result.generate.should be_true

      result = parse!( '--generate', '--deploy' )
      result.deploy.should be_true
      result.generate.should be_true
    end

    it "should turn on verbose when -w or --verbose is explicitly turned back on" do
      result = parse!( '-w' )
      result.verbose.should be_true

      result = parse!( '--verbose' )
      result.verbose.should be_true
    end

    it "should generate by default" do
      parse!().generate.should be_true
    end
  end

end
