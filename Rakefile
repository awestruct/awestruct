require 'rubygems'
require 'date'
require 'bundler/setup'
require 'rspec/core/rake_task'

def gem_name
  @gem_name ||= Dir['*.gemspec'].first.split('.').first
end

def gem_version
  line = File.read("lib/#{gem_name}/version.rb")[/^\s*VERSION\s*=\s*.*/]
  line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
end

def date
  Date.today.to_s
end

def gemspec_file
  "#{gem_name}.gemspec"
end

def gem_file
  "#{gem_name}-#{gem_version}.gem"
end

def version_tag
  "v#{gem_version}"
end

def replace_header(head, header_name)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
end

task :default => :build

if !defined?(RSpec)
  puts 'spec targets require RSpec'
else
  desc 'Run all specs'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = ['-cfs']
  end
end

desc "Run all specs and build #{gem_file} into the pkg directory"
task :build => [:spec, :gemspec] do
  sh "gem build #{gemspec_file}"
  sh 'mkdir -p pkg'
  sh "mv #{gem_file} pkg"
end

desc "Build #{gem_file} and install it locally"
task :install => :build do
  sh "gem install -l -f pkg/#{gem_file}"
end

desc "Update #{gemspec_file}"
task :gemspec do
  spec = File.read(gemspec_file)

  # replace name version and date
  replace_header(spec, :gem_name)
  replace_header(spec, :date)

  File.open(gemspec_file, 'w') { |io| io.write spec }
  puts "Updated #{gemspec_file}"
end

desc "Create tag #{version_tag} and push repository to origin"
task :tag do
  unless `git branch` =~ / master$/
    puts 'You must be on the master branch to release!'
    exit!
  end
  if version_tag.end_with?('.dev')
    puts 'You cannot tag and release a dev version!'
    exit!
  end

  if `git tag`.split(/\n/).include?(version_tag)
    puts "Tag #{version_tag} has already been created."
  else
    sh "git commit --allow-empty -a -m 'Release #{gem_version}'"
    sh 'git push origin master'
    sh "git tag #{version_tag}"
    sh "git push origin #{version_tag}"
  end
end
 
desc "Build #{gem_file}, create and push tag #{version_tag} and publish gem to RubyGems.org"
task :release => [ :build, :tag ] do
  sh "gem push pkg/#{gem_file}"
end

desc 'Run `spectator` to monitor changes and execute specs in TDD fashion'
task :tdd do
  sh 'spectator'
end
