
require 'awestruct/astruct'
require 'awestruct/page'

describe Awestruct::AStruct do 

  it "should initialize from hash provided in constructor" do
    s = Awestruct::AStruct.new( :foo=>'bar', 'taco'=>'tasty' )
    s[:foo].should == 'bar'
    s['taco'].should == 'tasty'
  end

  it "should allow access to members through indifferent hash access" do
    s = Awestruct::AStruct.new( :foo=>'bar', 'taco'=>'tasty' )
    s['foo'].should == 'bar'
    s[:foo].should == 'bar'

    s['taco'].should == 'tasty'
    s[:taco].should == 'tasty'
  end

  it "should allow method access to members" do
    s = Awestruct::AStruct.new( :foo=>'bar', 'taco'=>'tasty' )
    s.foo.should == 'bar'
    s.taco.should == 'tasty'
  end

  it "should cascade AStructs to inner array members" do 
    s = Awestruct::AStruct.new( :foo=>[ { 'taco'=>'tasty' } ] )
    s.foo.first.taco.should == 'tasty'
  end

  it "should preserve the actual array instance holding any inner structs" do
    inner_hash = { 'taco'=>'tasty' }
    array = [ inner_hash ]
    s = Awestruct::AStruct.new( :foo=>array )
    s.foo.first.taco.should == 'tasty'
    s.foo.object_id.should == array.object_id
  end

  it "should cascade AStruct to inner hash value structs" do
    s = Awestruct::AStruct.new( :foo=>{ 'taco'=>'tasty' } ) 
    s.foo.taco.should == 'tasty'
  end

  it "should allow any method to be called, resulting in nil" do
    s = Awestruct::AStruct.new( :foo=>'bar' )
    s.foo.should == 'bar'
    s.taco.should be_nil
  end

end
