desc 'DNSManager | Rebuild DB'
task :test do
	puts '!!!!'
end


namespace :dnsmgr do
	namespace :db do
		desc 'DNSManager | Rebuild DB'
		task rebuild: :environment do
			Rake::Task['dnsmgr:db:drop'].invoke
			Rake::Task['dnsmgr:db:init'].invoke
		end

		desc 'DNSManager | Migrate DB'
		task migrate: :environment do
			Rake::Task['db:migrate'].invoke
		end

		desc 'DNSManager | Build DB'
		task init: :environment do
			Rake::Task['db:migrate'].invoke
			Rake::Task['db:seed'].invoke
		end

		desc 'DNSManager | Drop DB'
		task drop: :environment do
			Rake::Task['db:drop'].invoke
		end
	end

	desc 'DNSManager | Start Service'
	task start: :environment do
		pid = `cat unicorn.pid 2> /dev/null`
		if pid.empty?
			puts 'DNSManager Starting...'
			`unicorn_rails -E production -c config/unicorn.rb -D`
			puts 'DNSManager Started!!'
		else
			puts 'DNSManager is still running.'
		end
	end

	desc 'DNSManager | Start Service without Daemon'
	task start_with_blocking: :environment do
		pid = `cat unicorn.pid 2> /dev/null`
		if pid.empty?
			puts 'DNSManager Starting...'
			`unicorn_rails -E production -c config/unicorn.rb`
			puts 'DNSManager Started!!'
		else
			puts 'DNSManager is still running.'
		end
	end

	desc 'DNSManager | Stop Service'
	task stop: :environment do
		pid = `cat unicorn.pid 2> /dev/null`
		if pid.empty?
			puts 'DNSManager is not running.'
		else
			puts 'DNSManager Exiting...'
			`kill -QUIT #{pid} 2> /dev/null`
			sleep 5
			puts 'DNSManager Exited!!'
		end
	end

	desc 'DNSManager | Restart Service'
	task restart: :environment do
		Rake::Task['dnsmgr:stop'].invoke
		Rake::Task['dnsmgr:start'].invoke
	end
end
