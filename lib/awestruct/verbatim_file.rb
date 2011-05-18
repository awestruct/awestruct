require 'awestruct/renderable_file'

module Awestruct

  class VerbatimFile < RenderableFile

    def initialize(site, source_path, relative_source_path, options = {})
      super( site, source_path, relative_source_path, options )
    end

  end
end
