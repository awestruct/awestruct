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
    t.pattern = 'spec/**/*.rb'
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

desc "Build and install the gem locally (for testing)"
task :install => :build do
  system "gem install -l -f #{GEMFILE}"
end

task :tag do
  system "git tag #{Awestruct::VERSION}"
end

task :tdd do
  system "spectator"
end

desc "Run RSpec in 1.9 mode and 1.8 mode"
task :test do
  system "jruby -S bundle exec rspec --tty --color spec"
  system "jruby --1.8 -S bundle exec rspec --tty --color spec"
end
