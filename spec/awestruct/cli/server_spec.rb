require 'awestruct/cli/server'
require 'awestruct/cli/options'
require 'socket'

describe Awestruct::CLI::Server do

  let(:subject) { Awestruct::CLI::Server.new('./')}

  it 'should abort if the port is already in use' do
    server = TCPServer.new(Awestruct::CLI::Options::DEFAULT_BIND_ADDR, Awestruct::CLI::Options::DEFAULT_PORT)
    expect(lambda {subject.run} ).to raise_error(SystemExit)
    server.close
  end
end