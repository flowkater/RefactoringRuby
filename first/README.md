## 첫번째 리팩토링
### 첫번째 리팩토링에서 사용한 리팩토링 기법 
- 메서드 추출(Extract Method)
- 메서드 이동(Move Method)
- 임시 변수를 메서드 호출로 전환(Replace Temp with Query)
- 루프를 컬렉션 클로저 메서드로 전환(Replace Loop with Collection)
- 타입 코드를 상태/전략 패턴으로 전환(Replace Type Code with State/Strategy)
- 필드 자체 캡슐화(Self Encapsulate Field)
- 모듈 추출(Extract Module)

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
**직관적인 코드를 위한 핵심요소가 바로 변수명이다.**  

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
**컴퓨터가 인식할 수 있는 수준의 코드는 유치원생도 작성할 수 있지만, 인간이 이해할 수 있는 코드는 실력 있는 프로그래머만이 작성할 수 있다.**  

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

위 amount_for 메서드를 보면 Rental 클래스 정보만 이용하고 Customer 클래스에 있는 정보는 이용하지 않음을 알 수 있다. **메서드 이동(Move Method)** 기법을 사용하여 Rental 클래스로 옮기자. Rental 클래스에 맞게 수정한다는 것은 매개변수 삭제를 뜻한다. 메서드를 옮기면서 메서드명도 바꿨다.  

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
**임시변수를 메서드 호출로 전환(Replace Temp with Query)**  

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

메서드 호출 중복으로 성능 이슈가 생긴다. 하지만 성능 문제를 이런 관점에서 바라보는 것은 바람직하지 않다. 리팩토링을 할 때는 명료성에 최우선적으로 집중하고, 각 작용에 따른 성능 문제는 그 다음에 생각해야 한다.  
**이 리팩토링에서 오히려 더 큰 문제는 charge 메서드가 반드시 멱등성(연산을 가해도 변하지 않는 성질)을 가져야 한다.**
  
임시 변수들을 제거하면 데이터 입출력 방법이 아니라 코드의 의도에 더 확실히 집중할 수 있다.  
  
적립 포인트 계산 부분을 **메서드 추출(Extract Method)** 기법을 이용하여 뽑아보자.  

```ruby
class Rental
	def frequent_renter_points
		# 최신물을 이틀 이상 대여하면 보너스 포인트를 더함
		movie.price_code == Movie::NEW_RELEASE && days_rented > 1 ? 2 : 1
	end	
end

### statement code => frequent_renter_points += element.frequent_renter_points
```
**리팩토링 각 단계는 소규모여야 실수가 생길 가능성이 줄어서 좋다. 할 때마다 테스트를 실행해주자**    
  
임시 변수를 메서드 호출로 전환(Replace Temp with Query)으로 total_amount 와 frequent_renter_points 를 질의 메서드로 바꿔보자.  
total_charge 에서 **루프를 컬렉션 클로저 메서드로 전환(Replace Loop with Collection)** 으로 훨씬 간단하게 리팩토링하였다. frequent_renter_points 도 마찬가지로 바꾸었다.  
```ruby
class Customer
	def statement
		result = "고객 #{@name}의 대여 기록\n"
		@rentals.each do |element|
			# 이번 대여의 계산 결과를 표시
			result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
		end
		# footer 행 추가
		result += "대여료는 #{total_charge}입니다.\n"
		result += "적립 포인트는 #{frequent_renter_points}입니다."
		result
	end

	private

	def total_charge
		@rentals.inject(0){|sum, rental| sum + rental.charge}
	end

	def frequent_renter_points
		@rentals.inject(0){sum, rental| sum + rental.frequent_renter_points }
	end	
end
```  

이번에도 성능 이슈가 있는데 리팩토링으로 코드를 간결화한 후에 프로파일러를 사용해서 성능 문제를 처리하면 된다.  
문제가 생겼다. 영화 종류를 더 다양하게 추가하고 가격 책정 방식을 바꾸고 싶은데 지금 구조에서는 일일이 다 추가를 해주어야한다. 리팩토링을 해보자.
일단 Rental에 있는 charge 메서드를 Movie 로 옮겼다. charge 메서드는 대여 기간과 영화 종류가 사용되는데 영화 종류가 바뀔 요구 사항이 있으니 Movie 클래스로의 이동이 적절하다.  
적립 포인트 계산 부분(frequent_renter_points)도 같이 옮기는 것이 맞다.  

```ruby
class Movie
	def charge(days_rented)
		result = 0
		case price_code
		when REGULAR
			result += 2
			result += (days_rented - 2) * 1.5 if days_rented > 2
		when NEW_RELEASE
			result += days_rented * 3
		when CHILDRENS
			result += 1.5
			result += (days_rented - 3) * 1.5 if days_rented > 3
		end
		result
	end

	def frequent_renter_points(days_rented)
		# 최신물을 이틀 이상 대여하면 보너스 포인트를 더함
		price_code == NEW_RELEASE && days_rented > 1 ? 2 : 1
	end
end

class Rental
	def frequent_renter_points
		movie.frequent_renter_points(days_rented)
	end
	

	def charge
		movie.charge(days_rented)
	end
end
```  

끝으로 상속 적용을 하는 데 단순히 상속 구조가 아닌 State Pattern 을 적용하여 (price가 하나의 상태가 될 수 있다.) 리팩토링을 해보자.  

**타입 코드를 상태/전략 패턴으로 전환(Replace Type Code with State/Strategy)**을 하기전에 **필드 자체 캡슐화(Self Encapsulate Field)**를 먼저 해서 클래스 캡슐화를 해주어야한다. (getter/setter)  

```ruby
class Movie
	# ...
	attr_reader :title, :price_code

	def price_code=(value)
		@price_code = value
		@price = case price_code
		when REGULAR then RegularPrice.new
		when NEW_RELEASE then NewReleasePrice.new
		when CHILDRENS then ChildrensPrice.new
		end
	end

	def initialize(title, the_price_code)
		@title, self.price_code = title, the_price_code
	end

	def charge(days_rented)
		@price.charge(days_rented)
	end
	# ...
end

class RegularPrice
	def charge(days_rented)
		result = 2
		result += (days_rented - 2) * 1.5 if days_rented > 2
		result
	end
end

class NewReleasePrice
	def charge(days_rented)
		days_rented * 3
	end
end

class ChildrensPrice
	def charge(days_rented)
		result = 1.5
		result += (days_rented - 3) * 1.5 if days_rented > 3
		result
	end
end
```  
frequent_renter_points 메서드에도 **모듈 추출(Extract Module)** 기법을 적용하여 그 모듈을 RegularPrice, ChildrensPrice 에 넣고 NewReleasePrice 안에는 특수한 frequent_renter_points 를 구현한다.  

```ruby
module DefaultPrice
	def frequent_renter_points(days_rented)
		1
	end
end

class RegularPrice
	include DefaultPrice
	# ...
end

class ChildrensPrice
	include DefaultPrice
	# ...
end

class NewReleasePrice
	def frequent_renter_points(days_rented)
		days_rented > 1 ? 2 : 1
	end
	# ...
end

class Movie
	# ...
	def frequent_renter_points(days_rented)
		@price.frequent_renter_points(days_rented)
	end
end
```  
case 문을 제거한 Movie 클래스 전체 코드를 살펴보자.  

```ruby
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
```  
State Pattern 을 적용하는 건 생각보다 복잡했지만 십 여개가 넘는 요금 관련 동작 및 메서드가 추가된다면 이렇게 하는 것이 추후 유지보수가 쉽게 된다.

### 결론
위의 여러 기법들을 통해 기능의 분배가 보다 균등해지고 코드의 유지보수가 수월해진다. 이 예제에서의 핵심은 '테스트' -> '사소한 수정' -> '테스트' -> '사소한 수정' 순으로 순환되는 리팩토링 리듬이다. 리팩토링이 신속하면서도 안전하게 이뤄질 수 있는 것은 바로 이 리듬 덕분이다.  
전체 리팩 토링 결과 코드는 위 저장소 코드를 참조하고 리팩토링 과정은 각 커밋로그를 좇아가면서 볼수있다.


















