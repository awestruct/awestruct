require 'awestruct/handler_chain'
require 'awestruct/handlers/verbatim_file_handler'
require 'awestruct/handlers/css_tilt_handler'
require 'awestruct/handlers/javascript_handler'
require 'awestruct/handlers/redirect_handler'
require 'awestruct/handlers/tilt_handler'
require 'awestruct/handlers/asciidoctor_handler'

module Awestruct

  class HandlerChains

    DEFAULTS = [
      Awestruct::Handlers::CssTiltHandler::CHAIN,
      Awestruct::Handlers::RedirectHandler::CHAIN,
      Awestruct::Handlers::JavascriptHandler::CHAIN,
      Awestruct::Handlers::AsciidoctorHandler::CHAIN,
      Awestruct::Handlers::TiltHandler::NON_INTERPOLATION_CHAIN,
      Awestruct::Handlers::TiltHandler::INTERPOLATION_CHAIN,
      HandlerChain.new( /.*/, Awestruct::Handlers::VerbatimFileHandler )
    ]

    def initialize(include_defaults=true)
      @chains = []
      self << :defaults if include_defaults

      # Register our sassc templates
      begin
        if require('sassc') || defined?(::Sassc)
          require 'awestruct/handlers/template/sassc'
          ::Tilt.register ::Awestruct::Tilt::SassSasscTemplate,'sass'
          ::Tilt.register ::Awestruct::Tilt::ScssSasscTemplate,'scss'
        end
      rescue LoadError
        # doesn't matter if we can't load it
      end
    end

    def[](path)
      @chains.detect{|e| e.matches?( path.to_s ) }
    end

    def <<(chain)
      @chains += DEFAULTS and return if ( chain == :defaults )
      @chains << chain
    end

  end

end
