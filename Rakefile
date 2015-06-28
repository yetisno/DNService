$PID_FILE='dnservice.pid'
def alive?(pid)
	begin
		Process.getpgid(pid.to_i)
		true
	rescue
		false
	end
end

def load_conf
	require 'active_support/core_ext/string/output_safety'
	require 'yaml'
	YAML.load(ERB.new(File.read(File.join('config', 'dnservice.yml'))).result)['dnservice']
end


task :secret do
	require 'securerandom'
	secret = SecureRandom.hex(64)
	puts secret
	secret
end

task :checkConfig do
	conf=load_conf
	if conf['db-connection-string'].nil?
		raise "db-connection-string can't be empty. Please set it at config/dnservice.yml or use environment variable DNS_DATABASE_URL"
	end
	if conf['reload-key'].nil?
		require 'securerandom'
		secret = SecureRandom.hex(64)
		raise "reload-key can't be empty. you can set reload-key: #{secret} at config/dnservice.yml or use environment variable DNS_RELOAD_KEY"
	end
end

task environment: :checkConfig do
	require_relative 'config/environment'
	if CONFIG['db-connection-string'].include?('sqlite3://')
		sqliteFile = CONFIG['db-connection-string'].gsub 'sqlite3://', ''
		File.copy_stream(File.join('assets', 'template.sqlite3'), sqliteFile) unless File.exist?(sqliteFile)
	end
end

desc 'DNService | Run Application (Not Daemon)'
task run: :environment do
	pid = `cat #{$PID_FILE} 2> /dev/null`
	if alive?(pid) && !pid.empty?
		puts 'DNService is still running.'
	else
		File.delete $PID_FILE if File.exist? $PID_FILE
		puts 'DNService Starting...'
		`ruby dnservice.rb`
	end
end

desc 'DNService | Start Service'
task start: :environment do
	pid = `cat #{$PID_FILE} 2> /dev/null`
	if alive?(pid) && !pid.empty?
		puts 'DNService is still running.'
	else
		File.delete $PID_FILE if File.exist? $PID_FILE
		puts 'DNService Starting...'
		fork do
			`ruby dnservice.rb`
		end
		puts 'DNService Started!!'
	end
end

desc 'DNService | Stop Service'
task :stop do
	pid = `cat #{$PID_FILE} 2> /dev/null`
	if alive?(pid) && !pid.empty?
		puts 'DNService Exiting...'
		`kill -QUIT #{pid} 2> /dev/null`
		`while ps -p #{pid} > /dev/null; do sleep 1; done`
		puts 'DNService Exited!!'
	else
		puts 'DNService is not running.'
	end
	File.delete $PID_FILE if File.exist? $PID_FILE
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
	File.delete 'log/DNService.log'
end
