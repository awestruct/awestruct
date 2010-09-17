
require 'rubygems'

Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "awestruct"
    s.version   =   "0.1.0"
    s.author    =   "Bob McWhirter"
    s.email     =   "bob@mcwhirter.org"
    s.summary   =   "Static site-baking utility"
    s.files     =   [
      Dir['lib/**/*.rb'],
      Dir['lib/**/*.haml'],
    ].flatten
    s.executables     =   [
      'awestruct',
    ].flatten
    s.require_paths  =   [ 'lib' ]
    s.has_rdoc  =   true

    s.add_dependency 'hpricot'
    s.add_dependency 'haml'
    s.add_dependency 'maruku'
    s.add_dependency 'compass'
    s.add_dependency 'compass-960-plugin'
    s.add_dependency 'mongrel'
    s.add_dependency 'org-ruby'
end

