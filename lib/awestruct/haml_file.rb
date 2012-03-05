require 'haml'
require 'open3'
require 'pathname'
require 'awestruct/front_matter_file'
require 'awestruct/hamlable'
require 'awestruct/asciidocable'
require 'awestruct/haml/filters/asciidoc'

module Awestruct
  class HamlFile < FrontMatterFile

    include Hamlable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      File.basename( self.source_path, '.haml' )
    end

    def output_extension
      File.extname( output_filename )
    end

  end
end
