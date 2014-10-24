require 'rexml/document'

module Awestruct
  module ContextHelper
    include REXML

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
      doc = Document.new text
      doc.context[:attribute_quote] = :quote  # Set double-quote as the attribute value delimiter

      XPath.each(doc, "//a") do |a|
        a.attributes['href'] = fix_url( base_url, a.attributes['href'] ) if a.attributes['href']
      end

      XPath.each(doc, "//link") do |link|
        link.attributes['href'] = fix_url( base_url, link.attributes['href'] )
      end

      XPath.each(doc, "//img") do |img|
        img.attributes['src'] = fix_url( base_url, img.attributes['src'] )
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
