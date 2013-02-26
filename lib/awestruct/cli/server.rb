require 'rack'
require 'rack/server'
require 'awestruct/rack/app'

module Awestruct
  module CLI
    class Server
      attr_reader :server

      def initialize(path, bind_addr='0.0.0.0', port=4242)
        @path      = path
        @bind_addr = bind_addr
        @port      = port
      end

      def run
        ::Rack::Server::start( :app => Awestruct::Rack::App.new( @path ),
                              :Port => @port,
                              :Host => @bind_addr
                             )
      end 
    end
  end
end
