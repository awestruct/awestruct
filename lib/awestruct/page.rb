
require 'awestruct/context'

require 'awestruct/handlers/no_op_handler'
require 'awestruct/handlers/page_delegating_handler'
require 'ostruct'
require 'awestruct/astruct'

module Awestruct

  class Page < Awestruct::AStruct

    attr_accessor :site
    attr_accessor :handler
    attr_reader   :dependencies

    def initialize(site, handler=nil)
      @site          = site
      case (handler)
        when Page
          @handler = Awestruct::Handlers::LayoutHandler.new( site, Awestruct::Handlers::PageDelegatingHandler.new( site, handler ) )
        when nil
          @handler = Awestruct::Handlers::NoOpHandler.new( site )
        else
          @handler = handler
      end
      @dependencies = Awestruct::Dependencies.new( self )
    end

    def prepare!
      handler.inherit_front_matter( self )
    end

    def inspect
      "Awestruct::Page{ #{self.object_id}: output_path=>#{output_path}, source_path=>#{source_path}, layout=>#{layout} }"
    end

    def create_context(content='')
      context = Awestruct::Context.new( :site=>site, :page=>self, :content=>content )
      site.engine.pipeline.mixin_helpers( context )
      context
    end

    def inherit_front_matter_from(hash)
      hash.each do |k,v|
        $LOG.debug "#{self.output_path} overwrite key: #{k}:#{self[k]} -> #{v}" if ( key?( k ) and !self[k].nil? and !self[k].eql? v) if $LOG.debug?
        unless ( key?( k ) )
          self[k.to_sym] = v
        end
      end
    end

    def relative_source_path
      @relative_source_path || handler.relative_source_path
    end

    def relative_source_path=(path)
      @relative_source_path = path
    end

    def simple_name
      handler.simple_name
    end

    def output_path
      (@output_path || handler.output_path).to_s
    end

    def output_path=(path)
      case ( path )
        when Pathname then @output_path = path
        else @output_path = Pathname.new( path )
      end
    end

    def output_extension
      handler.output_extension
    end

    def output_filename
      handler.output_filename
    end

    def source_path
      handler.path.to_s
    end

    def stale?
      handler.stale? || @dependencies.dependencies.any?(&:stale?)
    end

    def stale_output?(output_path)
      return true if ! File.exist?( output_path )
      return true if input_mtime > File.mtime( output_path )
      false
    end

    def input_mtime
      handler.input_mtime( self )
    end

    def collective_dependencies_mtime
      t = nil
      @dependencies.each do |e|
        if ( t == nil )
          t = e.mtime
        elsif ( t < e.mtime )
          t = e.mtime
        end
      end
      t
    end

    def all_dependencies
      @dependencies + handler.dependencies
    end

    def content_syntax
      handler.content_syntax
    end

    def raw_content
      handler.raw_content
    end

    def rendered_content(context=create_context(), with_layouts=true)
      if context.site.config.track_dependencies
        Awestruct::Dependencies.push_page( self )
      end
      c = nil

      begin
        $LOG.debug "calling rendered_content on handler for page #{self.output_path}" if $LOG.debug?
        c = handler.rendered_content( context, with_layouts )
        # c = site.engine.pipeline.apply_transformers( context.site, self, c )
      rescue => e
        raise $!, "Failed to render #{self.url}", $!.backtrace
      end

      if context.site.config.track_dependencies
        Awestruct::Dependencies.pop_page

        # temp disable traqcking when we collect the hash to not dirty the results
        Awestruct::Dependencies.track_dependencies = false
        if with_layouts
          @dependencies.content_hash = Digest::SHA2.hexdigest(c)

          # create a new Page so we can inherit the updated values not reflected in self
          tmp_page = Awestruct::Page.new @site
          @handler.inherit_front_matter(tmp_page)
          string_to_hash = tmp_page.to_a.each{|x| x[0]=x[0].to_s; x[1]=x[1].to_s; x}.sort.to_s
          hash = Digest::SHA2.hexdigest(string_to_hash)
          @dependencies.key_hash = hash
        end
        Awestruct::Dependencies.track_dependencies = true
      end
      c
    end

    def content(with_layouts=false)
      rendered_content( create_context(), with_layouts )
    end

    def ==(other_page)
      self.object_id == other_page.object_id
    end

  end
end
