require 'awestruct/handler_chain'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/interpolation_handler'
require 'awestruct/handlers/markdown_handler'
require 'awestruct/handlers/orgmode_handler'
require 'awestruct/handlers/textile_handler'
require 'awestruct/handlers/erb_handler'
require 'awestruct/handlers/haml_handler'
require 'awestruct/handlers/sass_handler'
require 'awestruct/handlers/scss_handler'
require 'awestruct/handlers/layout_handler'
require 'awestruct/handlers/page_delegating_handler'

module Awestruct

  class HandlerChains

    DEFAULTS = [
      HandlerChain.new( /\.md$/, 
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::MarkdownHandler,
        Awestruct::Handlers::LayoutHandler
      ),
      HandlerChain.new( /\.textile$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::TextileHandler,
        Awestruct::Handlers::LayoutHandler
      ),
      HandlerChain.new( /\.erb$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::ErbHandler,
        Awestruct::Handlers::LayoutHandler
      ),
      HandlerChain.new( /\.org$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::InterpolationHandler,
        Awestruct::Handlers::OrgmodeHandler,
        Awestruct::Handlers::LayoutHandler
      ),
      HandlerChain.new( /\.haml$/, 
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::FrontMatterHandler,
        Awestruct::Handlers::HamlHandler,
        Awestruct::Handlers::LayoutHandler
      ),
      HandlerChain.new( /\.sass$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::SassHandler
      ),
      HandlerChain.new( /\.scss$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::ScssHandler
      ),
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
