require 'sass'
require 'awestruct/front_matter_file'
require 'awestruct/orgmodeable'

module Awestruct
  class OrgmodeFile < FrontMatterFile

    include Orgmodeable

    def initialize(site, source_path, relative_source_path, options = {})
      super( site, source_path, relative_source_path, options )
    end

    def output_filename
      File.basename( self.source_path, '.org' ) + output_extension
    end

    def output_extension
      '.html'
    end

  end
end
