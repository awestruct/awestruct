require 'oga'
require 'awestruct/util/exception_helper'

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
      begin
        doc = Oga.parse_html text

        doc.each_node do |elem|
          if elem.is_a?(Oga::XML::Element) && elem.html?
            case elem.name
            when 'a'
              elem.set 'href', fix_url(base_url, elem.get('href')) if elem.get('href')
            when 'link'
              elem.set 'href', fix_url(base_url, elem.get('href')) if elem.get('href')
            when 'img'
              elem.set 'src', fix_url(base_url, elem.get('src')) if elem.get('src')
            end
          end
        end

        doc.to_xml.tap do |d|
          d.force_encoding(text.encoding) if d.encoding != text.encoding
        end
      rescue => e
        Awestruct::ExceptionHelper.log_error e
        $LOG.info %Q(If the error has to do with 'end of input' ensure none of the following tags have a closing tag:
#{Oga::XML::HTML_VOID_ELEMENTS.to_a.collect {|a| a.downcase}.uniq.join(', ')}) if $LOG.info?
        $LOG.warn "Text being parsed:\n#{text}" if $LOG.warn?
        text # returning the bad text, which hopefully will help find the cause
      end
    end

    def fix_url(base_url, url)
      return url unless ( url =~ /^\// )
      "#{base_url}#{url}"
    end
  end

end
