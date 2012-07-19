require File.expand_path("../lib/awestruct/version", __FILE__)

spec = Gem::Specification.new do |s|
    s.platform       =   Gem::Platform::RUBY
    s.name           =   "awestruct"
    s.version        =   Awestruct::VERSION
    s.author         =   "Bob McWhirter"
    s.email          =   "bob@mcwhirter.org"
    s.summary        =   "Static site-baking utility"
    s.description    =   "Awestruct is a framework for creating static HTML sites."
    s.homepage       =   "http://awestruct.org"
    s.files          =   [
      Dir['lib/**/*.rb'],
      Dir['lib/**/*.haml'],
    ].flatten
    s.executables    = [
      'awestruct',
    ].flatten
    s.require_paths  = [ 'lib' ]
    s.has_rdoc       = true

    s.add_dependency 'rack', '~> 1.4'
    s.add_dependency 'haml', '~> 3.1'
    s.add_dependency 'sass', '~> 3.1'
    s.add_dependency 'kramdown', '~> 0.13'
    s.add_dependency 'RedCloth', '~> 4.2'
    s.add_dependency 'coffee-script', '~> 2.2'
    s.add_dependency 'nokogiri', '~> 1.5'
    s.add_dependency 'compass', '~> 0.12'
    s.add_dependency 'compass-960-plugin', '~> 0.10'
    s.add_dependency 'bootstrap-sass', '~> 2.0'
    s.add_dependency 'org-ruby', '~> 0.5'
    s.add_dependency 'json', '~> 1.7'
    s.add_dependency 'rest-client', '~> 1.6.7'
    s.add_dependency 'git', '~> 1.2'

    s.add_dependency 'listen', '~> 0.4'
    s.add_dependency 'eventmachine', '~> 1.0.0.beta.4'
end
