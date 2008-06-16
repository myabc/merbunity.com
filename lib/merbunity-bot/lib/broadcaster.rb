# Broadcaster.setup("mongrel@domain.com/port4000", "test", "notify@domain.com/bot")
#
# Broadcaster.deliver("hello", ["user@domain"]) #=> sends a message to user@domain
# Broadcaster.deliver("bye my stuff")           #=> sends a message to everyone

require 'json'
require 'xmpp4r'

class Broadcaster
  def initialize(jid, pass, slave)
    @pass, @slave = pass, slave
    @client = Jabber::Client.new(jid)
    @client.on_exception do |*a|
      connect
    end
    @mutex = Mutex.new
    connect
  end

  def connect
    @client.connect
    @client.auth(@pass)
    pres = Jabber::Presence.new
    @client.send(pres)
    @ready = true
  end

  def ready?; @ready; end

  def deliver(body, rcpts)
    command = {"body" => body}
    command["rcpts"] = rcpts if rcpts
    msg = Jabber::Message.new(@slave, command.to_json)
    msg.type = :chat
    @mutex.synchronize do
      @client.send(msg)
    end
  end

  def self.setup(jid, pass, slave)
    Thread.new {
      @instance = new(jid, pass, slave)
    }
  end

  def self.instance; @instance; end

  def self.deliver(body, rcpts = nil)
    instance.deliver(body, rcpts) if instance && instance.ready?
  end
end

# vim:sts=2:ts=2:sw=2:et
