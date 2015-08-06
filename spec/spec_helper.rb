require 'rubygems'
require 'rspec'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config| 
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end
