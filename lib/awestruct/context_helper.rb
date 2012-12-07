require 'hpricot'
require 'uri'

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

    def fully_qualify_urls(base_url, text, context_path = nil)
      doc = Hpricot( text )

      doc.search( "//a" ).each do |a|
        a['href'] = fix_url( base_url, a['href'], context_path ) if a['href']
      end
      doc.search( "//link" ).each do |link|
        link['href'] = fix_url( base_url, link['href'], context_path )
      end
      doc.search( "//img" ).each do |img|
        img['src'] = fix_url( base_url, img['src'], context_path )
      end
      # Hpricot::Doc#to_s output encoding is not necessarily the same as the encoding of text
      if RUBY_VERSION.start_with? '1.8'
        doc.to_s
      else
        doc.to_s.tap do |d| 
          d.force_encoding(text.encoding) if d.encoding != text.encoding 
        end
      end
    end

    # prepend the base_url to absolute urls
    # if a context_path is specified, strip it before prepending the base_url
    def fix_url(base_url, url, context_path = nil)
      return url unless ( url =~ /^\// )
      if (context_path && context_path.size > 0 && url.slice(0..context_path.size-1) == context_path)
        "#{base_url}#{url.slice(context_path.size..-1)}"
      else
        "#{base_url}#{url}"
      end
    end
  end

end
