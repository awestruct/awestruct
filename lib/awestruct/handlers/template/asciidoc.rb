require 'tilt/template'

module Tilt
  class AsciidoctorTemplate < Template
    self.default_mime_type = 'text/html'

    def self.engine_initialized?
      defined? ::Asciidoctor::Document
    end

    def initialize_engine
      require_template_library 'asciidoctor'
    end

    def prepare
      options[:header_footer] = false if options[:header_footer].nil?
    end

    def evaluate(scope, locals, &block)
      @output ||= Asciidoctor.render(data, options, &block)
    end

    def allows_script?
      false
    end
  end
end