$:.push File.expand_path('../lib', __FILE__)
require 'awestruct/version'

spec = Gem::Specification.new do |s|
  s.name          = 'awestruct'
  s.version       = Awestruct::VERSION
  s.date          = '2013-09-14'

  s.authors       = ['Bob McWhirter', 'Jason Porter', 'Lance Ball', 'Dan Allen', 'Torsten Curdt', 'other contributors']
  s.email         = ['bob@mcwhirter.org', 'lightguard.jp@gmail.com', 'lball@redhat.com', 'dan.j.allen@gmail.com', 'tcurdt@vafer.org']
  s.homepage      = 'http://awestruct.org'
  s.summary       = 'Static site baking and publishing tool'
  s.description   = 'Awestruct is a static site baking and publishing tool. It supports an extensive list of both templating and markup languages via Tilt (Haml, Slim, AsciiDoc, Markdown, Sass via Compass, etc), provides mobile-first layout and styling via Bootstrap or Foundation, offers a variety of deployment options (rsync, git, S3), handles site optimizations (minification, compression, cache busting), includes built-in extensions such as blog post management and is highly extensible.'

  s.rubyforge_project = s.name

  s.license       = 'MIT'

  s.platform      = Gem::Platform::RUBY

  s.has_rdoc      = true
  s.rdoc_options  = ['--charset=UTF-8']
  s.extra_rdoc_files = 'README.md'

  s.files         = `git ls-files -z -- {lib,man,spec}/* {README,LICENSE}* *{.gemspec,file}`.split("\0")
  s.test_files    = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
  s.executables   = `git ls-files -z -- bin/*`.split("\0").map {|f| File.basename f }
  s.require_paths = ['lib']

  s.requirements    = <<-EOS
Any markup languages you are using and its dependencies.
Haml and Markdown filters are touchy things. Redcarpet or Rdiscount work well if you're running on MRI. JRuby should be using haml 4.0.0+ with Kramdown.'
  EOS

  s.add_dependency 'haml', '~> 4.0.1'
  s.add_dependency 'nokogiri', '1.5.10'
  s.add_dependency 'tilt', '>= 1.3.6'
  s.add_dependency 'compass', '>= 0.12.1'
  s.add_dependency 'compass-960-plugin', '~> 0.10.4'
  s.add_dependency 'bootstrap-sass', '>= 2.3.1.0'
  s.add_dependency 'zurb-foundation', '>= 4.0.9'
  s.add_dependency 'rest-client', '>= 1.6.7'
  s.add_dependency 'ruby-s3cmd', '~> 0.1.5'

  s.add_dependency 'listen', '>= 2.0.0'
  s.add_dependency 'rack', '~> 1.5.2'
end
