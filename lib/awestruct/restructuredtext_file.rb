require 'open3'
require 'awestruct/front_matter_file'
require 'awestruct/restructuredtextable'

module Awestruct
  class ReStructuredTextFile < FrontMatterFile

    include ReStructuredTextable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      File.basename( self.source_path, '.rst' ) + output_extension
    end

    def output_extension
      '.html'
    end

  end
end
