Merb.logger.info("Loaded DEVELOPMENT Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = true
  c[:reload_time] = 0.5
  c[:session_store] = 'memory'

}

class Merb::Mailer
 self.delivery_method = :test_send
end

Merb::BootLoader.before_app_loads do
  DataObjects::Sqlite3.logger = DataMapper::Logger.new(STDOUT, :debug)
end
