require 'mongrel'

module Awestruct
  module Commands

    #Mongrel::DirHandler::MIME_TYPES['.atom'] = 'text/plain'
    Mongrel::DirHandler::MIME_TYPES['.atom'] = 'application/atom+xml'

    class Server
      attr_reader :server

      def initialize(path, bind_addr='0.0.0.0', port=4242)
        @path      = path
        @bind_addr = bind_addr
        @port      = port
      end

      def run
        @server = Mongrel::HttpServer.new( @bind_addr, @port )
        handler = Mongrel::DirHandler.new( @path )
        @server.register("/", handler )
        @server.run.join
      end
    end
  end
end
