require 'awestruct/renderable_file'

module Awestruct

  class VerbatimFile < RenderableFile

    def initialize(site, source_path, relative_source_path, options = {})
      super( site, source_path, relative_source_path, options )
    end
    
    def raw_page_content
      IO.open(IO.sysopen(self.source_path, "rb"), "rb" ).read
    end
    
  end
  
end
