require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'git'

require File.join(File.dirname(__FILE__), 'lib', 'awestruct', 'version')

GEMFILE = "awestruct-#{Awestruct::VERSION}.gem" 

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
task :release => [:build, :tag, :push] do
  system "gem push #{GEMFILE}"
  puts "Done. Don't forget to update lib/awestruct/version.rb with the next version number."
end

task :tag => :check do
  git = Git.open('.')
  git.add_tag Awestruct::VERSION
end

task :push => :check do
  git = Git.open('.')
  git.push 
end

task :check do
  exit if has_uncommitted_changes?
end

desc "Build and install the gem locally (for testing)"
task :install => :build do
  system "gem install -l -f #{GEMFILE}"
end

def has_uncommitted_changes?
  git = Git.open('.')
  if !git.status.changed.empty? 
    puts "You have committed changes. Either stash or commit them before you continue"
    return true
  end
  return false
end
