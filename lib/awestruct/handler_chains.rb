require 'awestruct/handler_chain'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/markdown_handler'
require 'awestruct/handlers/orgmode_handler'
require 'awestruct/handlers/asciidoc_handler'
require 'awestruct/handlers/restructuredtext_handler'
require 'awestruct/handlers/textile_handler'
require 'awestruct/handlers/erb_handler'
require 'awestruct/handlers/haml_handler'
require 'awestruct/handlers/sass_handler'
require 'awestruct/handlers/scss_handler'
require 'awestruct/handlers/coffeescript_handler'

module Awestruct

  class HandlerChains

    DEFAULTS = [
      Awestruct::Handlers::MarkdownHandler::CHAIN,
      Awestruct::Handlers::TextileHandler::CHAIN,
      Awestruct::Handlers::ErbHandler::CHAIN,
      Awestruct::Handlers::OrgmodeHandler::CHAIN,
      Awestruct::Handlers::AsciidocHandler::CHAIN,
      Awestruct::Handlers::RestructuredtextHandler::CHAIN,
      Awestruct::Handlers::HamlHandler::CHAIN,
      Awestruct::Handlers::SassHandler::CHAIN,
      Awestruct::Handlers::ScssHandler::CHAIN,
      Awestruct::Handlers::CoffeescriptHandler::CHAIN,
      HandlerChain.new( /.*/, Awestruct::Handlers::FileHandler )
    ]

    def initialize(include_defaults=true)
      @chains = []
      self << :defaults if include_defaults
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
