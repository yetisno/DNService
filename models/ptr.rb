class Ptr < ActiveRecord::Base
	validates :ip_arpa, presence: true
	validates :to_name, presence: true
end
