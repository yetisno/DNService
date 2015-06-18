class Nameserver < ActiveRecord::Base
	validates :name, presence: true
	validates :to_ns, presence: true
end
