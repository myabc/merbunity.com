require 'rubygems'
require 'logger'
require 'yaml'
require 'json'
require 'set'
require 'xmpp4r'
require 'xmpp4r/roster'

$:.unshift File.dirname(__FILE__)

class Bot
  def self.logger
    @logger ||= Logger.new($stderr)
  end
  def logger; self.class.logger; end

  def start
    ::Jabber.debug = !!config["debug"]

    @client = Jabber::Client.new(config["jid"])
    @client.on_exception do |*a|
      logger.error "Got a client exception: #{a.inspect}"
      sleep 10
      connect
    end
    @client.add_presence_callback do |p|
      handle_presence(p)
    end
    @client.add_message_callback do |m|
      handle_message(m)
    end
    connect

    Thread.stop
  end

  def connect
    @client.connect
    @client.auth(config["pass"])
    @client.send(Jabber::Presence.new)
    @roster ||= Jabber::Roster::Helper.new(@client)
  end

  def handle_presence(pres)
    return if pres.type == :error
    return if pres.from.bare == @client.jid.bare

    case pres.type
    when :subscribe
      logger.info "Got a subscription request from #{pres.from}"
      @roster.accept_subscription(pres.from)
      alert_admins("#{pres.from} subscribed")
    when :unsubscribe
      logger.info "Got an unsubscription request from #{pres.from}"
      Thread.new {
        if @roster[pres.from].remove
          logger.info "#{pres.from} removed from the roster"
          alert_admins("#{pres.from} unsubscribed")
        else
          logger.warn "#{pres.from} not removed from the roster"
        end
      }
    end
  end

  def handle_message(msg)
    return if msg.type == :error
    return if msg.body.nil?

    logger.debug "Handling message: #{msg.inspect}"
    case access_for(msg.from)
    when :admin
      case msg.body
      when "ping"
        logger.info "ping from #{msg.from}"
        reply = Jabber::Message.new(msg.from, "pong")
        @client.send(reply)
      when "reload"
        logger.info "reload from #{msg.from}"
        @config = nil
        reply = Jabber::Message.new(msg.from, "Reloaded...")
        @client.send(reply)
      when "who"
        logger.info "who request from #{msg.from}"
        watchers = online_watchers
        body = "#{watchers.size} jids online: "
        body << watchers.join(", ")
        reply = Jabber::Message.new(msg.from, body)
        @client.send(reply)
      else
        logger.info "unknown message #{msg.body.inspect} from #{msg.from}"
        reply = Jabber::Message.new(msg.from, "what?")
        @client.send(reply)
      end
    when :controller
      parse_command(msg.from, msg.body)
    end
  end

  def parse_command(from, command_string)
    command = JSON.parse(command_string)
    rcpts = command["rcpts"] || online_watchers
    puts command["body"].inspect
    body = command["body"].gsub("&lt;", "<").gsub("&gt;", ">")

    logger.info "#{from} delivered #{body.inspect} to #{rcpts.inspect}"

    rcpts.each do |rcpt|
      msg = Jabber::Message.new(rcpt, "")

      # Create the html part
      h = REXML::Element::new("html")
      h.add_namespace('http://jabber.org/protocol/xhtml-im')

      # The body part with the correct namespace
      b = REXML::Element::new("body")
      b.add_namespace('http://www.w3.org/1999/xhtml')

      # The html itself
      t = REXML::Text.new( body, false, nil, true, nil, %r/.^/ )

      # Add the html text to the body, and the body to the html element
      b.add(t)
      h.add(b)

      # Add the html element to the message
      msg.add_element(h)

      msg.type = :chat
      @client.send(msg)
    end
  rescue
    logger.error "Failed to parse command: #{command_string.inspect} with #{$!.class}, #{$!.message}"
  end

  def online_watchers
    watchers = []
    @roster.items.each do |jid,item|
      watchers << jid.bare.to_s if item.online?
    end
    watchers
  end

  def access_for(jid)
    logger.debug "Checking access for #{jid}"
    if admins.include?(jid.bare.to_s)
      :admin
    elsif controllers.include?(jid.bare.to_s)
      :controller
    end
  end

  def alert_admins(body)
    admins.each do |rcpt|
      msg = Jabber::Message.new(rcpt, body)
      msg.type = :chat
      @client.send(msg)
    end
  end

  def admins
    config["admins"] || []
  end

  def controllers
    config["controllers"] || []
  end

  def config
    @config ||= YAML.load_file(File.dirname(__FILE__) + '/../data/config.yml')
  end
end

begin
  Bot.logger.debug "Starting on #{$$}"
  b = Bot.new
  b.start
rescue Exception => e
  Bot.logger.error "Caught exception: #{e.class}, #{e.message}"
  Bot.logger.debug e.backtrace.join("\n")
end

Bot.logger.debug "Finishing on #{$$}"

# vim:sts=2:ts=2:sw=2:et
