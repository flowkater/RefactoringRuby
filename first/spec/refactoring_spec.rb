# encoding: UTF-8
require 'customer'
require 'rental'
require 'movie'
require 'spec_helper'

describe "Refactoring" do
	let(:movie_regular) {Movie.new("프리퀀시",Movie::REGULAR)}
	let(:movie_new_release) {Movie.new("나우유씨미",Movie::NEW_RELEASE)}
	let(:movie_childrens) {Movie.new("드래곤볼",Movie::CHILDRENS)}

	let(:rental_regular_three){Rental.new(movie_regular,3)}
	let(:rental_regular_one){Rental.new(movie_regular,1)}
	let(:rental_new_release_two){Rental.new(movie_new_release, 2)}
	let(:rental_new_release_one){Rental.new(movie_new_release, 1)}
	let(:rental_childrens_four){Rental.new(movie_childrens, 4)}
	let(:rental_childrens_three){Rental.new(movie_childrens, 3)}

	let(:customer_guest) {Customer.new("Guest")}
	let(:customer_carter) {Customer.new("Carter")}
	let(:rental_record_string){"고객 Carter의 대여 기록"}

	describe "test" do
		it "customer test" do
			customer_guest.statement.should == "고객 Guest의 대여 기록\n대여료는 0입니다.\n적립 포인트는 0입니다."
		end

		it "movie test" do
			movie_regular.title.should == "프리퀀시"
			movie_regular.price_code.should == Movie::REGULAR

			movie_new_release.title.should == "나우유씨미"
			movie_new_release.price_code.should == Movie::NEW_RELEASE

			movie_childrens.title.should == "드래곤볼"
			movie_childrens.price_code.should == Movie::CHILDRENS
		end

		it "retal test" do
			rental_regular_three.movie.title.should == "프리퀀시"
			rental_regular_three.days_rented.should > 2
			rental_regular_one.days_rented.should < 2
		end
	end

	describe "statement" do
		it "when movie regular 3day more" do
			customer_carter.add_rental(rental_regular_three)
			customer_carter.statement.should == "고객 Carter의 대여 기록\n\t프리퀀시\t3.5\n대여료는 3.5입니다.\n적립 포인트는 1입니다."
			customer_carter.add_rental(rental_new_release_one)
			customer_carter.statement.should == "고객 Carter의 대여 기록\n\t프리퀀시\t3.5\n\t나우유씨미\t3\n대여료는 6.5입니다.\n적립 포인트는 2입니다."
		end
	end
end