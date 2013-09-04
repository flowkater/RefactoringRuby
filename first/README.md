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
















