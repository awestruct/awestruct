require 'awestruct/dependencies'

module Awestruct

  module AStructMixin

    def self.extended(o)
      class << o
        alias_method :original_entries, :entries
        undef entries
      end
    end

    def cascade_for_nils!
      @cascade_for_nils = true
      self
    end

    def key?(key)
      super( key ) || super( key.to_sym ) || super( key.to_s )
    end

    def [](key)
      r = [key, key.to_sym, key.to_s].find { |fk| !super(fk).nil? }
      transform_entry( key, super(r) )
    end

    def method_missing(sym, *args, &blk)
      type = sym.to_s[-1,1]
      name = sym.to_s.gsub(/[=!?]$/, '').to_sym
      case type
      when '='
        self[name] = args.first
      when '!'
        __send__(name, *args, &blk)
      when '?'
        self[name]
      else
        if key?(name)
          self[name]
        elsif @cascade_for_nils
          self[name] = AStruct.new.cascade_for_nils!
          self[name]
        else
          unless args.size.zero?
            $LOG.warn "Call to unknown method: #{name}"
          end
          nil
        end
      end
    end

    UNTRACKED_KEYS = [
      :url,
    ]

    def transform_entry(for_key, entry)
      r = case(entry)
        when AStructMixin
          entry
        when Hash
          #AStruct.new( entry )
          entry.extend( AStructMixin )
        when Array
          entry.map!{|i| transform_entry( for_key, i)}
        else
          entry
      end
      if ( self.is_a? Awestruct::Page )
        unless UNTRACKED_KEYS.include? for_key.to_sym
          Awestruct::Dependencies.track_key_dependency( self, for_key )
        end
      end
      r
    end

    def inspect
      "AStruct<#{super.to_s}>"
    end

  end

end
