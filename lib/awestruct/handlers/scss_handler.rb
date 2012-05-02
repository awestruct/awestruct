
require 'awestruct/handlers/base_sass_handler'

module Awestruct
  module Handlers
    class ScssHandler < BaseSassHandler

      def initialize(site, delegate)
        super( site, delegate, :scss )
      end

    end
  end
end
