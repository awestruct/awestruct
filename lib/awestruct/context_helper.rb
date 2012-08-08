require 'nokogiri'

module Awestruct
  module ContextHelper

    def html_to_text(str)
      str.gsub( /<[^>]+>/, '' ).gsub( /&nbsp;/, ' ' )
    end

    def clean_html(str)
      str.gsub( /&nbsp;/, ' ' )
    end

    def without_images(str)
      str.gsub(/<img[^>]+>/,'').gsub(/<a[^>]+>([^<]*)<\/a>/, '\1')
    end

    def close_tags(s)
      stack = []
      s.scan(/<\/?[^>]+>/).each do |tag|
        if tag[1] != '/'
          tag = tag[1..-1].scan(/\w+/).first
          stack = [ tag ] + stack
        else
          tag = tag[2..-1].scan(/\w+/).first
          if stack[0] == tag
            stack = stack.drop(1)
          else
            raise "Malformed HTML expected #{tag[0]} but got #{tag} '#{s}'"
          end
        end
      end
      stack.inject(s) { |memo,tag| memo += "</#{tag}>" }
    end

    def summarize(text, numwords=20, ellipsis='...')
      close_tags(text.split(/ /)[0, numwords].join(' ') + ellipsis)
    end

    def fully_qualify_urls(base_url, text)
      doc = Nokogiri::HTML::DocumentFragment.parse( text )

      doc.css( "a" ).each do |a|
        a.attributes['href'].value = fix_url( base_url, a.attributes['href'].value ) if a.attributes['href']
      end
      doc.css( "link" ).each do |link|
        link.attributes['href'].value = fix_url( base_url, link.attributes['href'].value )
      end
      doc.css( "img" ).each do |img|
        img.attributes['src'].value = fix_url( base_url, img.attributes['src'].value )
      end
      if RUBY_VERSION.start_with? '1.8'
        doc.to_s
      else
        doc.to_s.tap do |d|
          d.force_encoding(text.encoding) if d.encoding != text.encoding
        end
      end
    end

    def fix_url(base_url, url)
      return url unless ( url =~ /^\// )
      "#{base_url}#{url}"
    end
  end

end
