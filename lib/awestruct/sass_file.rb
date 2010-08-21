
require 'sass'
require 'awestruct/renderable_file'
require 'awestruct/sassable'

module Awestruct
  class SassFile < RenderableFile

    include Sassable

    def initialize(site, source_path, relative_source_path)
      super( site, source_path, relative_source_path )
    end
 
    def output_filename
      File.basename( source_path, '.sass' ) + '.css'
    end
  
    def syntax
      :sass
    end

  end
end
