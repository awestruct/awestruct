
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_sass_handler'
require 'awestruct/handlers/file_handler'

module Awestruct
  module Handlers
    class SassHandler < BaseSassHandler

      CHAIN = Awestruct::HandlerChain.new( /\.sass$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::SassHandler
      )

      def initialize(site, delegate)
        super( site, delegate, :sass )
      end

    end
  end
end
