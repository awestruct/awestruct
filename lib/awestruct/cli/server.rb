require 'rack'
require 'rack/server'
require 'awestruct/rack/app'

module Awestruct
  module CLI
    class Server
      attr_reader :server

      def initialize(path, bind_addr=Options::DEFAULT_BIND_ADDR, port=Options::DEFAULT_PORT)
        @path      = path
        @bind_addr = bind_addr
        @port      = port
      end

      def run
        url = %(http://#{Options::LOCAL_HOSTS[@bind_addr] || @bind_addr}:#{@port})
        msg = %(Starting preview server at #{url} (Press Ctrl-C to shutdown))
        puts %(#{'*' * msg.length}\n#{msg}\n#{'*' * msg.length}\n)
        ::Rack::Server::start( :app => Awestruct::Rack::App.new( @path ),
                              :Port => @port,
                              :Host => @bind_addr
                             )
      end 
    end
  end
end
