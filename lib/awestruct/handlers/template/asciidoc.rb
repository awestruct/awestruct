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

    def parse_headers(content, filter = /.*/)
      doc = Asciidoctor.load(content, {:parse_header_only => true})
      filtered = doc.attributes.select{|k,v| k =~ filter}.inject({}) do |hash, (k,v)|
        hash[k.gsub(filter, '')] = v
        hash
      end

      filtered["doctitle"] = doc.doctitle
      filtered["date"] ||= doc.attributes["revdate"] unless doc.attributes["revdate"].nil?
      filtered["author"] = doc.attributes["author"] unless doc.attributes["author"].nil?

      filtered
    end
  end
end