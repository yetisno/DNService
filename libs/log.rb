class Log

	@@log = Logger.new('log/DNService.log', shift_age = 'weekly')

	def self.d(message)
		@@log.debug message
	end

	def self.i(message)
		@@log.info message
	end

	def self.w(message)
		@@log.warn message
	end

	def self.e(message)
		@@log.error message
	end

	def self.f(message)
		@@log.fatal message
	end

	def self.level(level)
		@@log.level = level
	end
end