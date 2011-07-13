
require 'awestruct/front_matter_file'
require 'awestruct/markdownable'

module Awestruct
  class MarkdownFile < FrontMatterFile

    include Markdownable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      File.basename( self.source_path, '.md' ) + output_extension
    end

    def output_extension
      '.html'
    end

  end
end
