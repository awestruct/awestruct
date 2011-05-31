
require 'awestruct/renderable'

module Awestruct
  class RenderableFile < Renderable

    def initialize(site, source_path, relative_source_path, options = {})
      super( site )
      self.source_path          = source_path
      self.relative_source_path = relative_source_path
      self.options              = options
      unless ( relative_source_path.nil? )
        dir_name = File.dirname( relative_source_path )
        if ( dir_name == '.' )
          self.output_path          = output_filename
        else
          self.output_path          = File.join( dir_name, output_filename )
        end
      end
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
