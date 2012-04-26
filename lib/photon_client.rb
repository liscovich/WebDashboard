require 'eventmachine'
DIRNAME = File.dirname(File.expand_path(__FILE__))
module Photon
  autoload :Socket, "#{DIRNAME}/photon/socket"
  autoload :WebSocket, "#{DIRNAME}/photon/web_socket"
  autoload :Client, "#{DIRNAME}/photon/client.rb"
end

EM.run {
  client = Photon::Client.new

  client.connect('localhost', {port: 9090})

  client.add_event_listener 'connect' do
    p [:connect]
    client.join('my_room')
  end

  client.add_event_listener 'message' do |data|
    p [:message, data.inspect]
  end

  client.add_event_listener 'join' do |data|
    p [:join, data.inspect]
  end
}

