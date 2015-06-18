class Soa < ActiveRecord::Base
	validates :serial, presence: true, numericality: :only_integer
	validates :refresh, presence: true, numericality: :only_integer
	validates :retry, presence: true, numericality: :only_integer
	validates :expire, presence: true, numericality: :only_integer
	validates :minimum, presence: true, numericality: :only_integer
end
