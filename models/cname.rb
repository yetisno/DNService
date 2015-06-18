class Cname < ActiveRecord::Base
	validates :name, presence: true
	validates :to_name, presence: true
end
