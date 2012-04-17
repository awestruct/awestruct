require 'awestruct/front_matter_file'
require 'awestruct/coffeescriptable'
require 'coffee-script'

module Awestruct
  class CoffeeScriptFile < FrontMatterFile

    include CoffeeScriptable

    def initialize(site, source_path, relative_source_path, options = {})
      super(site, source_path, relative_source_path, options)
    end

    def output_filename
      File.basename( self.source_path, '.coffee' ) + output_extension
    end

    def output_extension
      '.js'
    end

  end
end
