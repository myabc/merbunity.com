merb_gems_version = "1.0.8"
dm_gems_version   = "0.9.10"

dependency "extlib",                    "=0.9.10"
dependency 'merb-core',                 merb_gems_version
dependency 'merb-gen',                  merb_gems_version, :require_as => nil
dependency "merb-action-args",          merb_gems_version
dependency 'merb-param-protection',     merb_gems_version
dependency "merb-assets",               merb_gems_version
dependency "merb-helpers",              merb_gems_version
dependency "merb-mailer",               merb_gems_version
dependency "merb-slices",               merb_gems_version
dependency "merb-auth-core",            merb_gems_version
dependency "merb-auth-more",            merb_gems_version
dependency "merb-auth-slice-password",  merb_gems_version
dependency "merb-param-protection",     merb_gems_version
# dependency "merb-exceptions",           merb_gems_version,  :require => 'merb-exceptions'

dependency "dm-core",                   dm_gems_version  
dependency "dm-aggregates",             dm_gems_version
dependency "dm-migrations",             dm_gems_version
dependency "dm-timestamps",             dm_gems_version
dependency "dm-types",                  dm_gems_version
dependency "dm-validations",            dm_gems_version 
dependency "do_sqlite3",                :require_as => nil
# dependency "do_postgres",               "=0.9.11", :require_as => nil
dependency "do_mysql",                  :require_as => nil

dependency "merb_datamapper",           merb_gems_version
dependency "merb-haml",                 merb_gems_version

dependency "cucumber",                  "0.1.13", :require_as  => nil
dependency "david-merb_cucumber",       :require_as => nil
dependency "faker",                     :require_as => nil
dependency "hassox-machinist",          "=0.1.7.1", :require_as => nil


