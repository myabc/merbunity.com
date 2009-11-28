Merb.logger.info("Loaded PRODUCTION Environment...")
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

Merb::BootLoader.before_app_loads do
  MA[:use_activation] = true unless Merb.env?(:development)
end
