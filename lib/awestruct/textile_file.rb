require 'awestruct/front_matter_file'
require 'awestruct/textilable'
require 'redcloth'

module Awestruct
  class TextileFile < FrontMatterFile

    include Textilable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      File.basename( self.source_path, '.textile' ) + output_extension
    end

    def output_extension
      '.html'
    end

  end
end
