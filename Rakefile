require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'awestruct/version'

GEMFILE = "awestruct-#{Awestruct::VERSION}.gem" 

task :default => :build

if !defined?(RSpec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = ['-cfs']
  end
end

desc "Run all tests and build the gem"
task :build => :spec do
  system "gem build awestruct.gemspec"
end
 
desc "Release the gem to rubygems"
task :release => [ :build, :tag ] do
  system "gem push #{GEMFILE}"
end

desc "Build and install the gem locally"
task :install => :build do
  system "gem install -l -f #{GEMFILE}"
end

task :tag do
  system "git tag #{Awestruct::VERSION}"
end

desc "Run `spectator` to monitor changes and execute specs in TDD fashion"
task :tdd do
  system "spectator"
end
