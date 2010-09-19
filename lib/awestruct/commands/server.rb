require 'webrick'

module Awestruct
  module Commands

    WEBrick::HTTPUtils::DefaultMimeTypes.store('atom', 'application/atom+xml')

    class Server
      attr_reader :server

      def initialize(path, bind_addr='0.0.0.0', port=4242)
        @path      = path
        @bind_addr = bind_addr
        @port      = port
      end

      def run
        @server = WEBrick::HTTPServer.new( :DocumentRoot=>@path, :Port=>@port, :BindAddress=>@bind_addr )
        @server.start
      end
    end
  end
end
