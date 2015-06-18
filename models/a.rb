class A < ActiveRecord::Base
	require 'resolv'
	validates :name, presence: true
	validates :to_ip, presence: true, :format => {:with => Resolv::IPv4::Regex}
end
