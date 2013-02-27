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
    s.version        =   "0.5.0"
    s.files          =   [
      Dir['lib/**/*.rb'],
      Dir['lib/**/*.haml'],
    ].flatten
    s.executables    = [
      'awestruct',
    ].flatten
    s.require_paths  = [ 'lib' ]
    s.has_rdoc       =   true

    s.requirements  << "Any markup languages you are using and it's dependencies" 
    s.requirements  << "If LESS is used, or some other fixes within tilt, it is required to use Bundler and the :git ref for the tilt gem"

    s.add_dependency 'hpricot', '~> 0.8.6'
    s.add_dependency 'nokogiri', '~> 1.5.6'
    s.add_dependency 'tilt', '~> 1.3.3'
    s.add_dependency 'compass', '~> 0.12.1'
    s.add_dependency 'compass-960-plugin', '~> 0.10.4'
    s.add_dependency 'bootstrap-sass', '~> 2.2.2.0'
    s.add_dependency 'json', '~> 1.6.6'
    s.add_dependency 'rest-client', '~> 1.6.7'
    s.add_dependency 'git', '~> 1.2.5'
    s.add_dependency 'htmlcompressor', '~> 0.0.3'
    s.add_dependency 'uglifier', '~> 1.3.0'
    s.add_dependency 'ruby-s3cmd', '~> 0.1.5'

    s.add_dependency 'listen', '~> 0.5.0'
    s.add_dependency 'rack', '~> 1.5.2'
    s.add_dependency 'eventmachine', '~> 1.0.0.rc.4'
end

