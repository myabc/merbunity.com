puts "Loaded DEVELOPMENT Environment..."

Merb::Mailer.config = {
   :host=>'email.octopus.com.au',
   :port=>'25',
   :user=>'dneighman',
   :pass=>'buggeroff',
   :auth=>:login # :plain, :login, :cram_md5
}

Merb::Mailer.config = {:sendmail_path => '/usr/sbin/sendmail'}
Merb::Mailer.delivery_method = :sendmail