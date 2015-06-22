require_relative 'config/environment'
$PID_FILE='dnservice.pid'
$RKEY_FILE='dnservice.rkey'

def reload_key
	CONFIG['reload-key'] || ENV['DNS_RELOAD_KEY'] || SecureRandom.hex(64)
end

task :environment do
	require 'securerandom'
	sqlFile = File.join 'db', 'dnservice.sqlite3'
	rKey = `cat #{$RKEY_FILE} 2> /dev/null`
	if rKey.empty?
		ENV['DNS_RELOAD_KEY'] = reload_key
	else
		rKey = CONFIG['reload-key'] if !CONFIG['reload-key'].blank?
		ENV['DNS_RELOAD_KEY'] = rKey
	end
	File.copy_stream File.join('assets', 'template.sqlite3'), sqlFile if !File.exist?(sqlFile) && ENV['DNS_DATABASE_URL'].blank?
	ENV['DNS_DATABASE_URL'] = ENV['DNS_DATABASE_URL'] || "sqlite3://#{ File.join(File.expand_path('..', __FILE__), sqlFile)}"
end

desc 'DNService | Run Application (Not Daemon)'
task run: :environment do
	File.write $RKEY_FILE, ENV['DNS_RELOAD_KEY']
	puts 'DNService Starting...'
	`ruby dnservice.rb`
end

desc 'DNService | Start Service'
task start: :environment do
	File.write $RKEY_FILE, ENV['DNS_RELOAD_KEY']
	pid = `cat #{$PID_FILE} 2> /dev/null`
	if pid.empty?
		puts 'DNService Starting...'
		fork do
			`ruby dnservice.rb`
		end
		puts 'DNService Started!!'
	else
		puts 'DNService is still running.'
	end
end

desc 'DNService | Stop Service'
task stop: :environment do
	pid = `cat #{$PID_FILE} 2> /dev/null`
	if pid.empty?
		puts 'DNService is not running.'
	else
		puts 'DNService Exiting...'
		`kill -QUIT #{pid} 2> /dev/null`
		`while ps -p #{pid} > /dev/null; do sleep 1; done`
		puts 'DNService Exited!!'
	end
	File.delete $PID_FILE if File.exist? $PID_FILE
	File.delete $RKEY_FILE if File.exist? $RKEY_FILE
end

desc 'DNService | Restart Service'
task restart: :environment do
	Rake::Task['stop'].invoke
	Rake::Task['start'].invoke
end

desc 'DNService | Status'
task status: :environment do
	pid = `cat #{$PID_FILE} 2> /dev/null`
	puts `if ps -p #{pid} > /dev/null; then echo "DNService is Running!"; else echo "DNService is not Running!"; fi`
end

desc 'DNService | Reload Record'
task reload: :environment do
	File.write $RKEY_FILE, ENV['DNS_RELOAD_KEY']
	Resolv::DNS.open(nameserver_port: [['127.0.0.1', CONFIG['bind-port']]]).
		getresources(reload_key, Resolv::DNS::Resource::IN::TXT)

end

desc 'DNService | Reset'
task reset: :environment do
	Rake::Task['stop'].invoke
	File.delete 'log/DNService.log'
end