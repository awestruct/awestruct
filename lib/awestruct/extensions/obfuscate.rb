module Awestruct
  module Extensions
    module Obfuscate

      def mail_to(email, options={})
        index = email.index('@') or raise "email needs to contain one @"
        index += 3

        headers = [ :subject, :body, :bcc, :cc ] & options.keys
        parameters = "?" + headers.map { |k| "#{k}=#{percent(options[k])}" }.join('&') if headers.length > 0

        if options[:title]
          content = options[:title]
        else
          account, domain = [ email[0...index], email[index..-1] ]
          content = "#{hex(account)}<!--\nmailto:abuse@hotmail.com\n</a>\n-->#{hex(domain)}"
        end

        "<a target='_blank' class='#{options[:class]}\nhref=\"mailto:x@y\"\n'\nhref\n =  '#{hex('mailto:' + email)}#{parameters}\n'>#{content}</a>"
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