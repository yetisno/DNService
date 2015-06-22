class DNServer
	BIND_IP = CONFIG['bind-ip']
	BIND_PORT = CONFIG['bind-port']
	TTL = CONFIG['ttl']
	RECURSIVE_QUERY = CONFIG['recursive-query']
	FORWARDER = RubyDNS::Resolver.new([[:udp, CONFIG['forwarder-ip'], CONFIG['forwarder-port']],
	                                   [:tcp, CONFIG['forwarder-ip'], CONFIG['forwarder-port']]])
	NAME = Resolv::DNS::Name
	TYPE = Resolv::DNS::Resource::IN

	def initialize
		@updated = true
		loadResources
	end

	def interfaces
		[
			[:udp, BIND_IP, BIND_PORT],
			[:tcp, BIND_IP, BIND_PORT]
		]
	end

	def mergeRecord(hash, key, record)
		if hash[key].blank?
			hash[key] = [record]
		else
			hash[key] += [record]
		end
	end

	def loadResources
		return if !@updated
		Log.d 'load resource'
		@as = {}
		@cnames = {}
		@mxes = {}
		@nameservers = {}
		@soas = {}
		@ptrs = {}

		Log.d 'load A record'
		A.all.each { |a|
			name = a.name.upcase
			mergeRecord @as, name, a
		}

		Log.d 'load CNAME record'
		Cname.all.each { |cname|
			name = cname.name.upcase
			mergeRecord @cnames, name, cname
		}

		Log.d 'load MX record'
		Mx.all.each { |mx|
			name = mx.name.upcase
			mergeRecord @mxes, name, mx
		}

		Log.d 'load NS record'
		Nameserver.all.each { |nameserver|
			name = nameserver.name.upcase
			mergeRecord @nameservers, name, nameserver
		}

		Log.d 'load SOA record'
		Soa.all.each { |soa|
			name = soa.name.upcase
			mergeRecord @soas, name, soa
		}

		Log.d 'load PTR record'
		Ptr.all.each { |ptr|
			name = ptr.ip_arpa.upcase
			mergeRecord @ptrs, name, ptr
		}
		@updated = false
	end

	def a_response(transaction, ip, question)
		transaction.respond!(ip, {:ttl => TTL, resource_class: TYPE::A, question: question})
	end

	def cname_response(transaction, name, question)
		transaction.respond!(NAME.create(name), {:ttl => TTL, resource_class: TYPE::CNAME, question: question})
	end

	def mx_response(transaction, name, priority, question)
		transaction.respond!(priority, NAME.create(name), {:ttl => TTL, resource_class: TYPE::MX, question: question})
	end

	def soa_response(transaction, name, contact, serial, refresh, pretry, expire, minimum, question)
		transaction.respond!(NAME.create(name),
		                     NAME.create(contact),
		                     serial,
		                     refresh,
		                     pretry,
		                     expire,
		                     minimum,
		                     {ttl: TTL, resource_class: TYPE::SOA, question: question})
	end

	def ns_response(transaction, name, question)
		transaction.respond!(NAME.create(name), {ttl: TTL, resource_class: TYPE::NS, question: question})
	end

	def ptr_response(transaction, name, question)
		transaction.respond!(NAME.create(name), {ttl: TTL, resource_class: TYPE::PTR, question: question})
	end

	def nxdomain_response(transaction)
		transaction.fail!(:NXDomain)
	end

	def a_handler(transaction)
		return if @as[@uQuestion].blank? && @cnames[@uQuestion].blank?
		if !@as[@uQuestion].blank?
			@as[@uQuestion].each { |a|
				a_response transaction, a.to_ip, @question
			}
		end
		if !@cnames[@uQuestion].blank?
			@cnames[@uQuestion].each { |cname|
				name = cname.to_name
				uName = name.upcase
				cname_response transaction, name, @question
				as = @as[uName]
				if as.blank?
					as.each { |a| a_response(transaction, a.to_ip, uName) }
				else
					FORWARDER.query(uName).answer.each do |ans|
						ans.each { |record|
							cname_response transaction, record.name.to_s, name if record.class ==TYPE::CNAME
							a_response transaction, record.address.to_s, name if record.class == TYPE::A
						}
					end
				end
			}
		end
		@matched = true
	end

	def cname_handler(transaction)
		return if @cnames[@uQuestion].blank?
		@cnames[@uQuestion].each { |cname|
			cname_response transaction, cname.to_name, @question
		}
		@matched = true
	end

	def mx_handler(transaction)
		return if @mxes[@uQuestion].blank?
		@mxes[@uQuestion].each { |mx|
			mx_response transaction, mx.to_name, mx.priority, @question
		}
		@matched = true
	end

	def soa_handler(transaction)
		return if @soas[@uQuestion].blank?
		@soas[@uQuestion].each { |soa|
			soa_response(transaction,
			             soa.name,
			             soa.contact,
			             soa.serial,
			             soa.refresh,
			             soa.retry,
			             soa.expire,
			             soa.minimum,
			             @question)
		}
		@matched = true
	end

	def ns_handler(transaction)
		return if @nameservers[@uQuestion].blank?
		@nameservers[@uQuestion].each { |nameserver|
			ns_response transaction, nameserver.to_ns, @question
		}
		@matched = true
	end

	def ptr_handler(transaction)
		return if @ptrs[@uQuestion].blank?
		@ptrs[@uQuestion].each { |ptr|
			ptr_response transaction, ptr.to_name, @question
		}
		@matched = true
	end

	def forward_query(transaction)
		transaction.passthrough!(FORWARDER)
	end

	def check_reload(resource_class)
		return @updated if !resource_class.eql? TYPE::TXT
		Log.i 'func: check_reload'
		@updated = (@uQuestion.include? CONFIG['reload-key'].upcase) &&
			                               (@uQuestion.length - CONFIG['reload-key'].length).abs < 10
		Log.i 'reload resource at next query.' if @updated
		@updated
	end

	def pre_match(transaction)
		@question = transaction.question.to_s
		@uQuestion = @question.upcase
		@matched = false
		loadResources
	end

	def post_match(transaction)
		if !@matched
			if RECURSIVE_QUERY
				Log.i 'forward query'
				forward_query transaction
			else
				nxdomain_response transaction if check_reload transaction.resource_class
			end
		end
	end

	def process(transaction)
		pre_match transaction
		a_handler transaction if transaction.resource_class.eql? TYPE::A
		cname_handler transaction if transaction.resource_class.eql? TYPE::CNAME
		mx_handler transaction if transaction.resource_class.eql? TYPE::MX
		ns_handler transaction if transaction.resource_class.eql? TYPE::NS
		soa_handler transaction if transaction.resource_class.eql? TYPE::SOA
		ptr_handler transaction if transaction.resource_class.eql? TYPE::PTR

		post_match transaction
	end
end