require_relative 'config/environment'
$PID_FILE='dnservice.pid'

task :environment do
	require 'securerandom'
	sqlFile = File.join 'db', 'dnservice.sqlite3'
	rKeyFile = 'dnservice.rkey'
	rKey = `cat #{rKeyFile} 2> /dev/null`
	if rKey.empty?
		ENV['DNS_RELOAD_KEY'] = ENV['DNS_RELOAD_KEY'] || SecureRandom.hex(64)
	else
		ENV['DNS_RELOAD_KEY'] = rKey
	end
	File.write rKeyFile, ENV['DNS_RELOAD_KEY']
	File.copy_stream File.join('assets', 'template.sqlite3'), sqlFile unless File.exist? sqlFile
	ENV['DNS_DATABASE_URL'] = ENV['DNS_DATABASE_URL'] || "sqlite3://#{ File.join(File.expand_path('..', __FILE__), sqlFile)}"
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
		getresources(CONFIG['reload-key'], Resolv::DNS::Resource::IN::TXT)

end

desc 'DNService | Reset'
task reset: :environment do
	Rake::Task['stop'].invoke
	File.delete 'dnservice.rkey'
	File.delete 'log/DNService.log'
end