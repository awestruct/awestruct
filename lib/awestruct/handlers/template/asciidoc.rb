require 'tilt'
require 'asciidoctor'

module Awestruct
  module Tilt
    class AsciidoctorTemplate < ::Tilt::Template
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
        @output ||= (scope.document = ::Asciidoctor.load(data, options, &block)).convert
      end

      def allows_script?
        false
      end

      def parse_headers(content, filter = /.*/)
        doc = ::Asciidoctor.load(content, {:parse_header_only => true})
        filtered = doc.attributes.select{|k,v| k =~ filter}.inject({}) do |hash, (k,v)|
          hash[k.gsub(filter, '')] = v
          hash
        end

        filtered['title'] = filtered['doctitle'] = doc.doctitle
        filtered['date'] ||= doc.attributes['revdate'] unless doc.attributes['revdate'].nil?
        if (cnt = doc.attributes['authorcount'].to_i) > 1
          authors = []
          (1..cnt).each do |idx|
            author = {}
            author[:name] = doc.attributes["author_#{idx}"]
            if doc.attributes.has_key? "email_#{idx}"
              author[:email] = doc.attributes["email_#{idx}"]
            end
            authors << author
          end
          filtered['author'] = authors.first[:name]
          filtered['email'] = authors.first[:email] if authors.first.has_key? :email
          filtered['authors'] = authors.to_yaml
        elsif !doc.attributes['author'].nil?
          author = {}
          author[:name] = doc.attributes['author']
          if doc.attributes.has_key? 'email'
            author[:email] = doc.attributes['email']
          end
          filtered['author'] = author[:name]
          filtered['authors'] = [author].to_yaml
        end

        filtered
      end
    end
  end
end

