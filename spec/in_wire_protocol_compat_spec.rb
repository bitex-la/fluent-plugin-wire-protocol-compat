require 'spec_helper'

describe Fluent::WireProtocolCompatInput do
  let(:port) { unused_port }
  let(:client) {
    u = Fluent::SocketUtil.create_udp_socket('127.0.0.1')
    u.connect('127.0.0.1', port)
    u
  }
  def send(arg)
    client.send("#{arg.to_json}\n", 0)
  end

  before :each do
    start_supervisor(<<-CONFIG)
      <source>
        type wire_protocol_compat
        <input>
          type udp
          port #{port}
          bind 127.0.0.1
          format json
          tag test
        </input>
      </source>

      <match **>
        type test
      </match>
    CONFIG
  end

  it 'handles regular events' do
    record = { 'foo' => 'bar' }
    send(record)
    tag, events = wait_until { Fluent::TestOutput.emitted.first }
    timestamp, event = events.first
    expect(tag).to eq 'test'
    expect(event).to eq record
  end

  it 'handles single events in forward format' do
    now = Time.now.to_i
    record = [ 'custom_tag', now, { 'foo' => 'bar' } ]
    send(record)
    tag, events = wait_until { Fluent::TestOutput.emitted.first }
    timestamp, event = events.first
    expect(tag).to eq 'custom_tag'
    expect(timestamp).to eq now
    expect(event).to eq record.last
  end

  it 'handles multiple events in forward format' do
    now = Time.now.to_i
    record = [ 'custom_tag', [
      [ now, { 'foo' => 'bar' } ],
      [ now + 1, { 'bar' => 'foo' } ]
    ] ]
    send(record)
    tag, events = wait_until { Fluent::TestOutput.emitted.first }
    expect(tag).to eq 'custom_tag'
    timestamp, event = events.first
    timestamp2, event2 = events.last
    expect(timestamp).to eq now
    expect(timestamp2).to eq now + 1

    expect(event).to eq({ 'foo' => 'bar' })
    expect(event2).to eq({ 'bar' => 'foo' })
  end
end
