# encoding: UTF-8
require 'regular_price'
require 'new_release_price'
require 'childrens_price'

class Movie
	attr_writer :price
	attr_reader :title, :price

	def initialize(title, price)
		@title, @price = title, price
	end

	def charge(days_rented)
		@price.charge(days_rented)
	end

	def frequent_renter_points(days_rented)
		@price.frequent_renter_points(days_rented)
	end
end