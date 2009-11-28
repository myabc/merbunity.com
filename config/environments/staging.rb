Merb.logger.info("Loaded STAGING Environment...")
Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:session_store] = 'cookie'
}

Merb::Mailer.config = {
  :host => "smtp.ey02.engineyard.com",
  :port => "25",
  :domain => "merbunity.com"
}
