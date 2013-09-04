## 첫번째 리팩토링
### statement 메서드 분해와 기능 재분배
- 메서드 추출(Extract Method)

```ruby
def statement
	total_amount, frequent_renter_points = 0, 0
	result = "고객 #{@name}의 대여 기록\n"
	@rentals.each do |element|
		this_amount = 0

		# 영화 종류별 내용을 각각 구함
		case element.movie.price_code
		when Movie::REGULAR
			this_amount += 2
			this_amount += (element.days_rented - 2) * 1.5 if element.days_rented > 2
		when Movie::NEW_RELEASE
			this_amount += element.days_rented * 3
		when Movie::CHILDRENS
			this_amount += 1.5
			this_amount += (element.days_rented - 3) * 1.5 if element.days_rented > 3
		end 

		# 적립 포인트를 더함
		frequent_renter_points += 1
		# 최신물을 이틀 이상 대여하면 보너스 포인트를 더함
		if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented >1
			frequent_renter_points += 1
		end
		# 이번 대여의 계산 결과를 표시
		result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
		total_amount += this_amount
	end
	# footer 행 추가
	result += "대여료는 #{total_amount}입니다.\n"
	result += "적립 포인트는 #{frequent_renter_points}입니다."
	result
end
```
case 문을 제일 먼저 리팩토링 해보자. element 변수명이 애매해서 넘어오는 파라미터인 rental로 변수명을 바꾸었다.  
** 직관적인 코드를 위한 핵심요소가 바로 변수명이다. **
```ruby
# 영화 종류별 내용을 각각 구함
def amount_for(rental)
	result = 0
	case rental.movie.price_code
	when Movie::REGULAR
		result += 2
		result += (rental.days_rented - 2) * 1.5 if rental.days_rented > 2
	when Movie::NEW_RELEASE
		result += rental.days_rented * 3
	when Movie::CHILDRENS
		result += 1.5
		result += (rental.days_rented - 3) * 1.5 if rental.days_rented > 3
	end
	result
end
```
위 메서드 추출을 통해서 좀 더 줄어든 statement 메서드를 볼 수 있다.  
** 컴퓨터가 인식할 수 있는 수준의 코드는 유치원생도 작성할 수 있지만, 인간이 이해할 수 있는 코드는 실력 있는 프로그래머만이 작성할 수 있다.**
```ruby
def statement
	total_amount, frequent_renter_points = 0, 0
	result = "고객 #{@name}의 대여 기록\n"
	@rentals.each do |element|
		this_amount = amount_for(element)

		# 적립 포인트를 더함
		frequent_renter_points += 1
		# 최신물을 이틀 이상 대여하면 보너스 포인트를 더함
		if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented >1
			frequent_renter_points += 1
		end
		# 이번 대여의 계산 결과를 표시
		result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
		total_amount += this_amount
	end
	# footer 행 추가
	result += "대여료는 #{total_amount}입니다.\n"
	result += "적립 포인트는 #{frequent_renter_points}입니다."
	result
end
```
위 amount_for 메서드를 보면 Rental 클래스 정보만 이용하고 Customer 클래스에 있는 정보는 이용하지 않음을 알 수 있다. ** 메서드 이동(Move Method) ** 기법을 사용하여 Rental 클래스로 옮기자. Rental 클래스에 맞게 수정한다는 것은 매개변수 삭제를 뜻한다. 메서드를 옮기면서 메서드명도 바꿨다.
```ruby
class Rental
	# ...
	def charge
		result = 0
		case movie.price_code
		when Movie::REGULAR
			result += 2
			result += (days_rented - 2) * 1.5 if days_rented > 2
		when Movie::NEW_RELEASE
			result += days_rented * 3
		when Movie::CHILDRENS
			result += 1.5
			result += (days_rented - 3) * 1.5 if days_rented > 3
		end
		result
	end
end

class Customer
	# ...
	def amount_for(rental)
		rental.charge
	end
	## -> 중복된 기능이니 굳이 이 메서드를 쓸 필요없다.
end
```
바뀐 코드를 다시 보자.
```ruby
def statement
	total_amount, frequent_renter_points = 0, 0
	result = "고객 #{@name}의 대여 기록\n"
	@rentals.each do |element|
		this_amount = element.charge ## this_amount

		# 적립 포인트를 더함
		frequent_renter_points += 1
		# 최신물을 이틀 이상 대여하면 보너스 포인트를 더함
		if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented >1
			frequent_renter_points += 1
		end
		# 이번 대여의 계산 결과를 표시
		result += "\t" + element.movie.title + "\t" + this_amount.to_s +  "\n" ## this_amount
		total_amount += this_amount ## this_amount
	end
	# footer 행 추가
	result += "대여료는 #{total_amount}입니다.\n"
	result += "적립 포인트는 #{frequent_renter_points}입니다."
	result
end
```
가끔 새 메서드로 처리를 넘기도록 기존 메서드를 놔둘 때도 있다. 메서드가 public 형이면서 나머지 클래스의 인터페이스를 건드리지 않아야 할 때는 이렇게 하는 것이 좋다.  
위 코드에서 this_amount 가 중복되는 것을 볼 수 있다.  
** 임시변수를 메서드 호출로 전환(Replace Temp with Query)
```ruby
def statement
	total_amount, frequent_renter_points = 0, 0
	result = "고객 #{@name}의 대여 기록\n"
	@rentals.each do |element|
		# 적립 포인트를 더함
		frequent_renter_points += 1
		# 최신물을 이틀 이상 대여하면 보너스 포인트를 더함
		if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented >1
			frequent_renter_points += 1
		end
		# 이번 대여의 계산 결과를 표시
		result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n" ####### change
		total_amount += element.charge ####### change
	end
	# footer 행 추가
	result += "대여료는 #{total_amount}입니다.\n"
	result += "적립 포인트는 #{frequent_renter_points}입니다."
	result
end
```











