require 'rubygems'
require 'rspec'
require 'simplecov'

SimpleCov.start

Dir["./spec/support/**/*.rb"].each {|f| require f} 

RSpec.configure do |config| 
  config.mock_framework = :rspec
end
