
require 'sass'
require 'awestruct/file_page'

module Awestruct
  class SassFilePage < FilePage

    include Sassable

    def initialize(site, path)
      super( site, path )
    end
 
    def output_filename
      File.basename( source_path, '.sass' ) + '.css'
    end

  end
end
