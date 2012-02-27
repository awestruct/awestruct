require 'open3'
require 'pathname'
require 'awestruct/front_matter_file'
require 'awestruct/asciidocable'

module Awestruct
  class AsciiDocFile < FrontMatterFile

    include AsciiDocable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      self.source_path.gsub(/\.(asciidoc|adoc)$/, output_extension)
    end

    def output_extension
      '.html'
    end

  end
end
