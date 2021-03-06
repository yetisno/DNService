require_relative 'config/environment'
$stdout.sync = true
class DNService
	server = DNServer.new
	File.write 'dnservice.pid', Process.pid
	RubyDNS::run_server(listen: server.interfaces) do
		match /.*/ do |transaction|
			server.process transaction
		end
	end
end
