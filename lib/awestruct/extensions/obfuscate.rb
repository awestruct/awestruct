module Awestruct
  module Extensions
    module Obfuscate

      def mail_to(email, options={})
        index = email.index('@') or raise "email needs to contain @"
        index += 3
        parts = [ email[0...index], email[index..-1] ]
        "<a\nclass='#{options[:class]}\nhref=\"mailto:x@y\"\n'\nhref\n =  '#{hex('mailto:' + percent(email))}\n'>#{hex(parts[0])}<!--\nmailto:abuse@hotmail.com\n</a>\n-->#{hex(parts[1])}</a>"
      end

      private

      def hex(s)
        result = ''
        s.each_codepoint do |cp|
          result << "&#x%x;" % [cp]
        end
        result
      end

      def percent(s)
        result = ''
        s.each_codepoint do |cp|
          result << "%%%x" % [cp]
        end
        result
      end

    end
  end
end