
require 'awestruct/front_matter_file'
require 'awestruct/marukuable'

module Awestruct
  class MarukuFile < FrontMatterFile

    include Marukuable

    def initialize(site, source_path, relative_source_path)
      super(site, source_path, relative_source_path)
    end

    def output_filename
      File.basename( self.source_path, '.md' ) + output_extension
    end

    def output_extension
      '.html'
    end

  end
end
