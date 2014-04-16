
require 'awestruct/handler_chain'
require 'awestruct/handler_chains'

describe Awestruct::HandlerChains do

  it "should perform matching in-order" do

    chains = Awestruct::HandlerChains.new(false)

    chain1 = Awestruct::HandlerChain.new( /foot/ )
    chain2 = Awestruct::HandlerChain.new( /foo/ )
    chain3 = Awestruct::HandlerChain.new( /.*/ )

    chains << chain1
    chains << chain2
    chains << chain3

    chains[ 'foot' ].should == chain1
    chains[ 'foo' ].should  == chain2
    chains[ 'hand' ].should == chain3

  end

end
