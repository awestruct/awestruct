require 'rubygems'
require 'rspec'
require 'logger'
require 'fileutils'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before :all do
    FileUtils.mkdir_p('_test_tmp/_config') unless File.exists? '_test_tmp/_config'
    FileUtils.mkdir('.awestruct') unless File.exists? '.awestruct'
    $LOG = Logger.new('.awestruct/test.log')
    File.open '_test_tmp/_config/site.yml', 'w' do |f|
      f.puts '---'
      f.puts 'encoding: UTF-8'
    end
  end
  config.mock_framework = :rspec
  config.include NokogiriMatchers
  config.include EmmetMatchers
  config.after :all do
    FileUtils.rm_rf '.awestruct' if !File.exists? '.awestruct'
    FileUtils.rm_rf '_test_tmp' unless !File.exists? '_test_tmp'
  end
end
