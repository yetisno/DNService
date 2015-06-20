require_relative 'config/environment'
$PID_FILE='dnservice.pid'

task :environment do
	require 'securerandom'
	sqlfile = 'dnservice.sqlite3'
	rkey = `cat dnservice.rkey 2> /dev/null`
	if rkey.empty?
		ENV['DNS_RELOAD_KEY'] = ENV['DNS_RELOAD_KEY'] || SecureRandom.hex(64)
	else
		ENV['DNS_RELOAD_KEY'] = rkey
	end
	File.write 'dnservice.rkey', ENV['DNS_RELOAD_KEY']
	File.copy_stream File.join('assets', 'template.sqlite3'), sqlfile unless File.exist? sqlfile
	ENV['DNS_DATABASE_URL'] = ENV['DNS_DATABASE_URL'] || "sqlite3://#{ File.join(File.expand_path('..', __FILE__), sqlfile)}"
end

desc 'DNService | Run Application (Not Daemon)'
task run: :environment do
	puts 'DNService Starting...'
	`ruby dnservice.rb`
end

desc 'DNService | Start Service'
task start: :environment do
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
		File.delete $PID_FILE
		puts 'DNService Exited!!'
	end
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
	Resolv::DNS.open(nameserver_port: [['127.0.0.1', CONFIG['bind-port']]]).
		getresources(ENV['DNS_RELOAD_KEY'], Resolv::DNS::Resource::IN::TXT)

end

desc 'DNService | Reset'
task reset: :environment do
	Rake::Task['stop'].invoke
	File.delete 'dnservice.rkey'
	File.delete 'log/DNService.log'
end