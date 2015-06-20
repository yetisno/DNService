class Mx < ActiveRecord::Base
	validates :question, presence: true
	validates :priority, presence: true, numericality: :only_integer
	validates :to_name, presence: true
end
