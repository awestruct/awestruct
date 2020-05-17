require 'spec_helper'
require 'awestruct/cli/init'
require 'logger'

describe Awestruct::CLI::Init do
  before(:each) do
    FileUtils.mkdir_p 'spec/support/clean_init'
  end

  after(:each) do
    FileUtils.rm_rf 'spec/support/clean_init'
  end

  it "should not fail during init without framework" do
    init = Awestruct::CLI::Init.new('spec/support/clean_init')
    expect(init.run).to eql true
  end
  it "should not fail during init with foundation" do
    init = Awestruct::CLI::Init.new('spec/support/clean_init', 'foundation', true)
    expect(init.run).to eql true
  end
  it "should not fail during init with bootstrap" do 
    init = Awestruct::CLI::Init.new('spec/support/clean_init', 'bootstrap', true)
    expect(init.run).to eql true 
  end
end
