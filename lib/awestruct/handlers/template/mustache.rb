require 'tilt/template'

module Tilt
  class MustacheTemplate < Template

    def self.engine_initialized?
      defined? ::Mustache
    end

    def initialize_engine
      require_template_library 'mustache'
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= Mustache.render(data, scope)
    end

    def allows_script?
      false
    end
  end
end