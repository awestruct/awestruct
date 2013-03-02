
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_tilt_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'
require 'awestruct/handlers/layout_handler'

require 'tilt'

module Awestruct
  module Handlers

    class TiltMatcher
      def match(path)
        !Tilt[path].nil?
      end
    end

    class NonInterpolatingTiltMatcher
      EXT_REGEX = /\.(haml|slim|erb|mustache)/

      def match(path)
        if match = EXT_REGEX.match(path)
          if match[0] == '.slim' && !defined?(Slim)
            require 'slim'
          end
          true
        else
          false
        end
      end
    end

    class TiltHandler < BaseTiltHandler

      INTERPOLATION_CHAIN = Awestruct::HandlerChain.new( Awestruct::Handlers::TiltMatcher.new(),
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::TiltHandler,
        Awestruct::Handlers::LayoutHandler
      )

      NON_INTERPOLATION_CHAIN = Awestruct::HandlerChain.new( Awestruct::Handlers::NonInterpolatingTiltMatcher.new(),
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::TiltHandler,
        Awestruct::Handlers::LayoutHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

    end

  end
end

require 'awestruct/handlers/template/mustache'
Tilt::register Tilt::MustacheTemplate, '.mustache'

require 'awestruct/handlers/template/asciidoc'
Tilt::register Tilt::AsciidoctorTemplate, '.ad', '.adoc', '.asciidoc'
