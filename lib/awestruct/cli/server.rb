require 'rack'
require 'rack/builder'
require 'rack/server'
require 'awestruct/rack/app'
require 'awestruct/rack/generate'

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
        url = %(http://#{Options::LOCAL_HOSTS[@bind_addr] || @bind_addr}:#{@port})
        msg = %(Starting preview server at #{url} (Press Ctrl-C to shutdown))
        puts %(#{'*' * msg.length}\n#{msg}\n#{'*' * msg.length}\n)

        path = @path
        generate_on_access = @generate_on_access
        app = ::Rack::Builder.new do
          use Awestruct::Rack::GenerateOnAccess if generate_on_access
          map "/" do
            run Awestruct::Rack::App.new( path )
          end
        end

          ::Rack::Server::start( :app => app,
                                :Port => @port,
                                :Host => @bind_addr
                               )
      end 
    end
  end
end