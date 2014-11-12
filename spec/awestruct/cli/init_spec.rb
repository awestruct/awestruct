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

  it "should not fail during init" do 
    init = Awestruct::CLI::Init.new('spec/support/clean_init', 'compass', true)
    expect(init.run).to eql true # There may be some sort of race condition here
  end
end
