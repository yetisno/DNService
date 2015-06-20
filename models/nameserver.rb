class Nameserver < ActiveRecord::Base
	validates :question, presence: true
	validates :to_ns, presence: true
end
