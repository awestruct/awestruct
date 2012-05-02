
require 'awestruct/handler_chain'

require 'hashery/open_cascade'

describe Awestruct::HandlerChain do

  class BaseMockHandler 
    attr_reader :site, :arg
    def initialize(site, arg)
      @site, @arg = site, arg
    end
  end

  class HandlerOne   < BaseMockHandler; end
  class HandlerTwo   < BaseMockHandler; end
  class HandlerThree < BaseMockHandler; end


  before :all do
    @site = OpenCascade.new :encoding=>false
  end

  it "should use a regexp to match" do
    chain = Awestruct::HandlerChain.new( /foo/ )
    chain.should be_matches( "foot" )
    chain.should_not be_matches( "hand" )
  end

  it "should nest handlers in order, first being deepest" do
    chain = Awestruct::HandlerChain.new( /foo/ )
    chain.handler_classes << HandlerOne
    chain.handler_classes << HandlerTwo
    chain.handler_classes << HandlerThree

    result = chain.create( @site, "foot" )

    result.should be_a HandlerThree
    result.arg.should be_a HandlerTwo
    result.arg.arg.should be_a HandlerOne
    result.arg.arg.arg.should == "foot"
  end

end
