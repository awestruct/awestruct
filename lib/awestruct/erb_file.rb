
require 'haml'
require 'awestruct/front_matter_file'
require 'awestruct/erbable'

module Awestruct
  class ErbFile < FrontMatterFile

    include Erbable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      File.basename( self.source_path, '.erb' )
    end

    def output_extension
      File.extname( output_filename )
    end

  end
end
