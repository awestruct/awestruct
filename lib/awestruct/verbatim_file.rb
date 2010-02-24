require 'awestruct/page'

module Awestruct

  class VerbatimFile < Page

    def initialize(site, source_path)
      super( site, source_path )
    end

    def render(context)
      File.read( source_path )
    end

  end
end
