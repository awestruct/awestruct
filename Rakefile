require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'awestruct/version'

task :default => :build

if !defined?(RSpec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*.rb'
    t.rspec_opts = ['-cfs']
  end
end

desc "Run all tests and build the gem"
task :build => :spec do
  system "gem build awestruct.gemspec"
end
 
desc "Release the gem to rubygems"
task :release => :build do
  system "gem push awestruct-#{Awestruct::VERSION}.gem"
end
