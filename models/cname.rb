class Cname < ActiveRecord::Base
	validates :question, presence: true
	validates :to_name, presence: true
end
