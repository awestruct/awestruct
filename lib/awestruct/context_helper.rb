require 'hpricot'

module Awestruct
  module ContextHelper
    
    def html_to_text(str)
      str.gsub( /<[^>]+>/, '' ).gsub( /&nbsp;/, ' ' )
    end
 
    def clean_html(str)
      str.gsub( /&nbsp;/, ' ' )
    end
  
    def summarize(text, numwords=20)
      text.split()[0, numwords].join(' ')
    end
  
    def fully_qualify_urls(base_url, text)
      doc = Hpricot( text )
   
      doc.search( "//a" ).each do |a|
        a['href'] = fix_url( base_url, a['href'] )
      end
      doc.search( "//link" ).each do |link|
        link['href'] = fix_url( base_url, link['href'] )
      end
      doc.search( "//img" ).each do |img|
        img['src'] = fix_url( base_url, img['src'] )
      end
      return doc.to_s
    end
  
    def fix_url(base_url, url)
      return url unless ( url =~ /^\// )
      "#{base_url}#{url}"
    end
  end

end
