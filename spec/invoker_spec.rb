
require 'awestruct/cli/invoker'

describe Awestruct::CLI::Invoker do

  it "should invoke generation by default" do
    invoker = Awestruct::CLI::Invoker.new
    invoker.should_not_receive( :invoke_init )
    invoker.should_not_receive( :invoke_script )
    invoker.should_not_receive( :invoke_force )
    invoker.should_receive( :invoke_generate )
    invoker.should_not_receive( :invoke_deploy )
    invoker.should_not_receive( :invoke_auto )
    invoker.should_not_receive( :invoke_server )
    invoker.invoke!
  end

  it "should only invoke initialization things when initializing" do
    invoker = Awestruct::CLI::Invoker.new( '--init' )
    invoker.should_receive( :invoke_init )
    invoker.should_not_receive( :invoke_script )
    invoker.should_not_receive( :invoke_force )
    invoker.should_not_receive( :invoke_generate )
    invoker.should_not_receive( :invoke_deploy )
    invoker.should_not_receive( :invoke_auto )
    invoker.should_not_receive( :invoke_server )
    invoker.invoke!
  end

  it "should invoke generation and server when servered" do
    invoker = Awestruct::CLI::Invoker.new( '--server' )
    invoker.should_not_receive( :invoke_init )
    invoker.should_not_receive( :invoke_script )
    invoker.should_not_receive( :invoke_force )
    invoker.should_receive( :invoke_generate )
    invoker.should_not_receive( :invoke_deploy )
    invoker.should_not_receive( :invoke_auto )
    invoker.should_receive( :invoke_server )
    invoker.invoke!
  end

 it "should invoke generation and server and auto when dev-mode" do
    invoker = Awestruct::CLI::Invoker.new( '-d' )
    invoker.should_not_receive( :invoke_init )
    invoker.should_not_receive( :invoke_script )
    invoker.should_not_receive( :invoke_force )
    invoker.should_receive( :invoke_generate )
    invoker.should_not_receive( :invoke_deploy )
    invoker.should_receive( :invoke_auto )
    invoker.should_receive( :invoke_server )
    invoker.invoke!
  end

end
