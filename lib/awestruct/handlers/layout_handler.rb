
require 'awestruct/handlers/base_handler'

module Awestruct
  module Handlers
    class LayoutHandler < BaseHandler

      def initialize(site, delegate)
        super( site, delegate )
      end

      def input_mtime(page)
        t = delegate.input_mtime( page )
        for_layout_chain(page) do |layout|
          layout_mtime = layout.input_mtime
          if ( t == nil )
            t = layout_mtime
          elsif ( layout_mtime > t )
            t = layout_mtime
          end
        end
        page_mtime = delegate.input_mtime( page )
        t
      end

      def inherit_front_matter(page)
        delegate.inherit_front_matter( page )
        for_layout_chain(page) do |layout|
          page.inherit_front_matter_from( layout )
        end 
      end

      def for_layout_chain(page, &block)
        current_page = page 
        $LOG.debug "layout_chain for #{current_page.inspect}" if $LOG.debug?
        while ( ! ( current_page.nil? || current_page.layout.nil? ) )
          current_page = site.layouts.find_matching( current_page.layout, current_page.output_extension )
          $LOG.debug "found matching layout #{current_page.inspect}" if $LOG.debug?
          if ( ! current_page.nil? )
            $LOG.debug "calling: #{block.inspect}" if $LOG.debug?
            block.call( current_page )
          end
        end
      end

      def rendered_content(context, with_layouts=true)
        content = delegate.rendered_content( context, with_layouts )

        if ( with_layouts ) 
          for_layout_chain(context.__effective_page || context.page) do |layout|
            context.content = content
            context.__effective_page = layout
            content = layout.rendered_content( context, false )
           end
        end

        content
      end

    end
  end
end
