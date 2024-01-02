$:.push File.expand_path('../lib', __FILE__)
require 'awestruct/version'

spec = Gem::Specification.new do |s|
  s.name          = 'awestruct'
  s.version       = Awestruct::VERSION
  s.date          = '2024-01-02'

  s.authors       = ['Bob McWhirter', 'Jason Porter', 'Lance Ball', 'Dan Allen', 'Torsten Curdt', 'other contributors']
  s.email         = ['bob@mcwhirter.org', 'lightguard.jp@gmail.com', 'lball@redhat.com', 'dan.j.allen@gmail.com', 'tcurdt@vafer.org']
  s.homepage      = 'https://awestruct.github.io'
  s.summary       = 'Static site baking and publishing tool'
  s.description   = 'Awestruct is a static site baking and publishing tool. It supports an extensive list of both templating and markup languages via Tilt (Haml, Slim, AsciiDoc, Markdown, Sass via Compass, etc), provides mobile-first layout and styling via Bootstrap or Foundation, offers a variety of deployment options (rsync, git, S3), handles site optimizations (minification, compression, cache busting), includes built-in extensions such as blog post management and is highly extensible.'

  s.license       = 'MIT'
  s.metadata = {
    'bug_tracker_uri'       => 'https://github.com/awestruct/awestruct/issues',
    'changelog_uri'         => 'https://github.com/awestruct/awestruct/releases',
    'source_code_uri'       => 'https://github.com/awestruct/awestruct'
  }
  s.platform      = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.4.0'

  s.rdoc_options  = ['--charset=UTF-8']
  s.extra_rdoc_files = 'README.md'

  s.files         = Dir.glob(["lib/**/*", "man/**/*", "spec/**/*", "spec/**/.awestruct_ignore", "README*", "LICENSE*", "*.gemspec", "*file"]).reject {|fn| File.directory?(fn) }
  s.test_files    = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
  s.executables   = Dir.glob("bin/*").map {|f| File.basename f }
  s.require_paths = ['lib']

  s.requirements    = <<-EOS
Any markup languages you are using and its dependencies.
Haml and Markdown filters are touchy things. Redcarpet or Rdiscount work well if you're running on MRI. JRuby should be using haml 4.0.0+ with Kramdown.
Compass and sass are no longer hard dependencies. You'll need too add them on your own should you want them. We also should be able to work with sassc.
  EOS

  s.add_dependency 'haml', '>= 4.0.5', '< 6.0'
  s.add_dependency 'asciidoctor', '>= 1.5.2'
  s.add_dependency 'tilt', '~> 2.0', '>= 2.0.1'
  s.add_dependency 'mime-types', '~> 3.0'
  s.add_dependency 'rest-client', '~> 2.0'
  s.add_dependency 'listen', '~> 3.1'
  s.add_dependency 'rack', '~> 2.0'
  s.add_dependency 'git', '~> 1.2', '>= 1.2.6'
  s.add_dependency 'guard', '~> 2.0', '>= 2.13.0'
  s.add_dependency 'guard-livereload', '~> 2.0', '>= 2.1.2'
  s.add_dependency 'logging', '~> 2.2'
  s.add_dependency 'oga', '~> 2.0'
  s.add_dependency 'parallel', '~> 1.0', '> 1.1.1'

  s.add_development_dependency 'nokogiri', '>= 1.5.10'
  s.add_development_dependency 'compass-960-plugin', '~> 0.10','>= 0.10.4'
  s.add_development_dependency 'bootstrap-sass', '>= 3.2.0.2'
  s.add_development_dependency 'zurb-foundation', '>= 4.3.2'
  s.add_development_dependency 'rspec', '>= 3.0'
  s.add_development_dependency 'guard-rspec', '>= 4.0'
end
