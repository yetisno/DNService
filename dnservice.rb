require_relative 'config/environment'
require 'logger'
$stdout.sync = true
class DNService
	Celluloid.logger.level = 1
	server = DNServer.new
	File.write 'dnservice.pid', Process.pid
	RubyDNS::run_server(listen: server.interfaces) do
		match /.*/ do |transaction|
			server.process transaction
		end
	end
end
