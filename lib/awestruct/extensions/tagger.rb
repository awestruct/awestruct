require 'awestruct/extensions/extend_string'

module Awestruct
  module Extensions
    class Tagger

      class TagStat
        attr_accessor :pages
        attr_accessor :group
        attr_accessor :primary_page
        def initialize(tag, pages)
          @tag   = tag
          @pages = pages
        end

        def to_s
          @tag
        end
      end

      module TagLinker
        attr_accessor :tags
        def tag_links(delimiter = ', ', style_class = nil)
          class_attr = (style_class ? ' class="' + style_class + '"' : '')
          tags.map{|tag| %Q{<a#{class_attr} href="#{tag.primary_page.url}">#{tag}</a>}}.join(delimiter)
        end
      end

      def initialize(tagged_items_property, input_path, output_path='tags', opts={})
        @tagged_items_property = tagged_items_property
        @input_path  = input_path
        @output_path = output_path
        @sanitize = opts[:sanitize] || false
        @pagination_opts = opts
      end

      def execute(site)
        @tags ||= {}
        all = site.send( @tagged_items_property )
        return if ( all.nil? || all.empty? ) 

        all.each do |page|
          tags = page.tags
          if ( tags && ! tags.empty? )
            tags.each do |tag|
              tag = tag.to_s
              @tags[tag] ||= TagStat.new( tag, [] )
              @tags[tag].pages << page
            end
          end
        end

        all.each do |page|
          page.tags = (page.tags||[]).collect{|t| @tags[t]}
          page.extend( TagLinker )
        end

        ordered_tags = @tags.values
        ordered_tags.sort!{|l,r| -(l.pages.size <=> r.pages.size)}
        #ordered_tags = ordered_tags[0,100]
        ordered_tags.sort!{|l,r| l.to_s <=> r.to_s}

        min = 9999
        max = 0

        ordered_tags.each do |tag|
          min = tag.pages.size if ( tag.pages.size < min )
          max = tag.pages.size if ( tag.pages.size > max )
        end

        span = max - min
        
        if span > 0
          slice = span / 6.0
          ordered_tags.each do |tag|
            adjusted_size = tag.pages.size - min
            scaled_size = adjusted_size / slice
            tag.group = (( tag.pages.size - min ) / slice).ceil
          end
        else
          ordered_tags.each do |tag|
            tag.group = 0
          end
        end

        @tags.values.each do |tag|
          ## Optionally sanitize tag URL
          output_prefix = File.join( @output_path, sanitize(tag.to_s) )
          options = { :remove_input=>false, :output_prefix=>output_prefix, :collection=>tag.pages }.merge( @pagination_opts )
          
          paginator = Awestruct::Extensions::Paginator.new( @tagged_items_property, @input_path, options )
          primary_page = paginator.execute( site )
          tag.primary_page = primary_page
        end

        site.send( "#{@tagged_items_property}_tags=", ordered_tags )
      end

      def sanitize(string)
        #replace accents with unaccented version, go lowercase and replace and space with dash
        if @sanitize
          string.to_s.urlize({:convert_spaces=>true})
        else
          string
        end
      end
    end
  end
end
