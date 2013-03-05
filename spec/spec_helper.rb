require 'rubygems'
require 'rspec'
require 'logger'
require 'fileutils'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before :all do
    FileUtils.mkdir '.awestruct'
  end
  config.mock_framework = :rspec
  config.include NokogiriMatchers
  config.after :all do
    FileUtils.rm_rf '.awestruct'
  end
end

$LOG = Logger.new(STDOUT)
