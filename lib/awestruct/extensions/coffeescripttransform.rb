require 'coffee-script'
require 'nokogiri'

##
# Awestruct:Extensions:CoffeeScript is a transformer that compiles inline CoffeeScript in HTML files as JavaScript.

module Awestruct
  module Extensions
    class CoffeeScriptTransform

      def transform(site, page, input)
        ext = File.extname(page.output_path)[1..-1].to_sym
        case ext
        when :html
          encoding = 'UTF-8'
          encoding = site.encoding unless site.encoding.nil?

          return compile(input, encoding)
        end
        return input
      end

      private

      def compile(input, encoding)
        html = Nokogiri::HTML(input, nil, encoding);
        html.search('script').each  do |script|
          next unless 'text/coffeescript'.eql? script.attr('type')

          if script.attr('src') =~ /\.coffee$/
            script.set_attribute('src', File.basename( script.attr('src'), '.coffee' ) + '.js')
          else
            script.inner_html = CoffeeScript.compile script.inner_html
          end
          script.set_attribute('type', 'text/javascript')

        end
        return html.to_html
      end
    end
  end
end
