
require 'awestruct/handler_chain'
require 'awestruct/handlers/base_sass_handler'
require 'awestruct/handlers/file_handler'

module Awestruct
  module Handlers
    class ScssHandler < BaseSassHandler

      CHAIN = Awestruct::HandlerChain.new( /\.scss$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::ScssHandler
      )

      def initialize(site, delegate)
        super( site, delegate, :scss )
      end

    end
  end
end
