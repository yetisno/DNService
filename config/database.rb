ActiveRecord::Base.establish_connection(CONFIG['db-connection-string']) unless CONFIG['db-connection-string'].blank?