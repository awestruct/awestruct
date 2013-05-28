require File.expand_path("../lib/awestruct/version", __FILE__)

spec = Gem::Specification.new do |s|
    s.platform       =   Gem::Platform::RUBY
    s.name           =   "awestruct"
    s.version        =   Awestruct::VERSION
    s.author         =   "Bob McWhirter and other contributors"
    s.email          =   "bob@mcwhirter.org"
    s.summary        =   "Static site-baking utility"
    s.description    =   "Awestruct is a framework for creating static HTML sites."
    s.homepage       =   "http://awestruct.org"
    s.files          =   [
      Dir['lib/**/**'],
      Dir['spec/**/**'],
      Dir['man/*.1'],
    ].flatten
    s.executables    = [
      'awestruct',
    ].flatten
    s.require_paths  = [ 'lib' ]
    s.has_rdoc       =   true

    s.requirements  << "Any markup languages you are using and its dependencies" 
    s.requirements  << "If LESS is used, or some other fixes within tilt, it is required to use Bundler and the :git ref for the tilt gem"
    s.requirements  << "Haml and markdown filters are touchy things. Rdiscount works well if you're running on mri. jRuby should be using haml 4.0.0 with kramdown"

    s.add_dependency 'haml', '~> 4.0.1'
    s.add_dependency 'nokogiri', '>= 1.5.6'
    s.add_dependency 'tilt', '>= 1.3.6'
    s.add_dependency 'compass', '>= 0.12.1'
    s.add_dependency 'compass-960-plugin', '~> 0.10.4'
    s.add_dependency 'bootstrap-sass', '>= 2.3.1.0'
    s.add_dependency 'zurb-foundation', '>= 4.0.9'
    s.add_dependency 'json', '>= 1.7.7'
    s.add_dependency 'rest-client', '>= 1.6.7'
    s.add_dependency 'git', '~> 1.2.5'
    s.add_dependency 'ruby-s3cmd', '~> 0.1.5'

    s.add_dependency 'listen', '>= 0.7.3'
    s.add_dependency 'rack', '~> 1.5.2'
end

