require 'awestruct/rack/debug'
require 'rack/test'

describe Awestruct::Rack::Debug do

  class TestObject

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def to_s
      @name
    end
  end

  def debug
    Awestruct::Rack::Debug.new("")
  end

  def model
    obj = ::Awestruct::Page.new({})
    obj.A = {:a_one => 1, :a_two => 2}
    obj.B = {:b_one => 1}
    obj.C = {:c_one => [{:c_one_sub => 1}, {:c_two_sub => 2}]}
    obj.CUST = {:obj => [TestObject.new('CUST_OBJ')]}
    return obj
  end

  it "should include empty next level" do

    struct = debug.introspect(model, {}, ['A'], depth = 3)

    struct.size.should == 1
    struct[:A].size.should == 0

  end

  it "should include next level on *" do

    struct = debug.introspect(model, {}, ['*', 'A'], depth = 3)

    struct.size.should == 1
    struct[:A].size.should == 2
    struct[:A][:a_one].should == 1
    struct[:A][:a_two].should == 2

  end

  it "should include empty array on next level" do

    struct = debug.introspect(model, {}, ['c_one', 'C'], depth = 3)

    puts struct

    struct.size.should == 1
    struct[:C].size.should == 1
    struct[:C][:c_one].size.should == 2
    expect(struct[:C][:c_one][0]).to be_empty
    expect(struct[:C][:c_one][1]).to be_empty

  end

  it "should include full array on next level" do

    struct = debug.introspect(model, {}, ['*', 'c_one', 'C'], depth = 3)

    puts struct

    struct.size.should == 1
    struct[:C].size.should == 1
    struct[:C][:c_one].size.should == 2
    expect(struct[:C][:c_one][0]).not_to be_empty
    expect(struct[:C][:c_one][1]).not_to be_empty

  end

  it "should include array index on next level" do

    struct = debug.introspect(model, {}, ['*', '1', 'c_one', 'C'], depth = 3)

    puts struct

    struct.size.should == 1
    struct[:C].size.should == 1
    struct[:C][:c_one].size.should == 2
    expect(struct[:C][:c_one][0]).to be_empty
    expect(struct[:C][:c_one][1]).not_to be_empty

  end

  it "should to_s custom objects" do

    struct = debug.introspect(model, {}, ['*', 'obj', 'CUST'], depth = 3)

    puts struct

    struct.size.should == 1
    struct[:CUST].size.should == 1
    struct[:CUST][:obj].size.should == 1
    expect(struct[:CUST][:obj][0]).not_to be_empty

  end
end
