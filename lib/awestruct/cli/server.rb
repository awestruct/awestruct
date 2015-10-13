require 'rack'
require 'rack/builder'
require 'rack/server'
require 'awestruct/rack/app'
require 'awestruct/rack/debug'
require 'awestruct/rack/generate'
require 'awestruct/cli/options'

module Awestruct
  module CLI
    class Server
      attr_reader :server

      def initialize(path, bind_addr=Options::DEFAULT_BIND_ADDR, port=Options::DEFAULT_PORT, generate_on_access=Options::DEFAULT_GENERATE_ON_ACCESS)
        @path      = path
        @bind_addr = bind_addr
        @port      = port
        @generate_on_access = generate_on_access
      end

      def run
        unless port_open? @bind_addr, @port
          $LOG.error "#{@bind_addr}:#{@port} not available for server" if $LOG.error?
          abort
        end
        url = %(http://#{@bind_addr}:#{@port})
        msg = %(Starting preview server at #{url} (Press Ctrl-C to shutdown))
        $LOG.info %(#{'*' * msg.length}\n#{msg}\n#{'*' * msg.length}\n) if $LOG.info?

        path = @path
        generate_on_access = @generate_on_access
        app = ::Rack::Builder.new do
          use Awestruct::Rack::GenerateOnAccess if generate_on_access
          use Awestruct::Rack::Debug
          map "/" do
            run Awestruct::Rack::App.new( path )
          end
        end

          ::Rack::Server::start(:app => app,
                                :Port => @port,
                                :Host => @bind_addr
                               )
      end 

      private
      # Private. Checks to see if the port is open.
      def port_open?(addr, port)
        begin
          s = TCPServer.new(addr, port)
          s.close
          true
        rescue  
          false
        end
      end
    end
  end
end
