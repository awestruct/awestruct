require 'tilt'
require 'sassc'

module Awestruct
  module Tilt
    class SassSasscTemplate < ::Tilt::SassTemplate
      self.default_mime_type = 'text/css'

      def prepare
        @engine = ::SassC::Engine.new(data, sass_options)
      end
    end
    class ScssSasscTemplate < ::Tilt::ScssTemplate
      self.default_mime_type = 'text/css'

      def prepare
        @engine = ::SassC::Engine.new(data, sass_options)
      end
    end
  end
end
