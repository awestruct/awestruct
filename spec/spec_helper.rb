require 'rubygems'
require 'rspec'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.include NokogiriMatchers
end
