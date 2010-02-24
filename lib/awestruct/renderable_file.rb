
require 'awestruct/renderable'

module Awestruct
  class RenderableFile < Renderable

    def initialize(site, source_path, relative_source_path)
      super( site )
      self.source_path          = source_path
      self.relative_source_path = relative_source_path
      self.output_path          = File.join( File.dirname( relative_source_path ), output_filename )
    end

    def raw_page_content
      File.read( self.source_path )
    end

    def render(context)
      raw_page_content
    end

    def output_extension
      File.extname( self.source_path )
    end

    def output_filename
      File.basename( self.source_path )
    end

  end
end
