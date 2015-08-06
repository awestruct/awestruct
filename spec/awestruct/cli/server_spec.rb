require 'awestruct/cli/server'
require 'awestruct/cli/options'
require 'socket'
require 'timeout'

describe Awestruct::CLI::Server do

  let(:subject) { Awestruct::CLI::Server.new('./')}

  it 'should abort if the port is already in use' do
    server = class_double(TCPServer).as_stubbed_const(:transfer_nested_constants => true)
    expect(server).to receive(:new).and_raise(Errno::EADDRINUSE)
    expect(lambda { Timeout.timeout(0.2) { subject.run } }).to raise_error(SystemExit)
  end
end
