
require 'sass'
require 'awestruct/front_matter_file'
require 'awestruct/org_modeable'

module Awestruct
  class OrgModeFile < FrontMatterFile

    include OrgModeable

    def initialize(site, source_path, relative_source_path)
      super( site, source_path, relative_source_path )
    end

    def output_filename
      File.basename( self.source_path, '.org' ) + output_extension
    end

    def output_extension
      '.html'
    end

  end
end
