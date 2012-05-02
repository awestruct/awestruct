
require 'awestruct/handlers/base_sass_handler'

module Awestruct
  module Handlers
    class SassHandler < BaseSassHandler

      def initialize(site, delegate)
        super( site, delegate, :sass )
      end

    end
  end
end
