#### Functions

##### Default Parameter Values and Named Arguments

```kotlin
fun printMessage(message: String): Unit { // Unit을 반환하는 함수 (즉, 반환 값 없음)
    println(message)
}

fun printMessageWithPrefix(message: String, prefix: String = "Info") { // optional parameter with default value "Info"
    println("[$prefix] $message")
}

fun sum(x: Int, y: Int): Int { // 
    return x + y
}

fun multiply(x: Int, y: Int) = x * y // 정수로 '추론'된 값을 반환하는 단일 표현식 함수

fun main() {
    printMessage("Hello")
    printMessageWithPrefix("Hello", "Log")
    printMessageWithPrefix("Hello")
    printMessageWithPrefix(prefix = "Log", message = "Hello") // 파라미터 순서를 바꾸어도 가능
    println(sum(1, 2))
    println(multiply(2, 4))
}
```

> Output
>
> ```
> Hello
> [Log] Hello
> [Info] Hello
> [Log] Hello
> 3
> 8
> ```

---

##### Infix Functions (중위 함수)

* 클래스의 멤버 호출 시 사용하는 점(.)과 함수 이름 뒤의 소괄호를 생략하여 직관적인 이름으로 표현하는 방법
* 중위 함수 조건 
  1. 멤버 메서드 또는 확장 함수여야 한다. 
  2. 하나의 매개변수를 가져야 한다. 
  3. infix 키워드를 사용하여야 한다.
* **mutableListOf**
  * List 면서 수정, 삭제가 가능한(Mutable) 리스트의 경우 사용하는 것으로 ArrayList와 유사하게 사용된다. (컴파일 시에는 ArrayList, MutableList 모두 List로 인식 됨)
  * ArrayList가 MutableList 인터페이스를 상속받은 구현체임

```kotlin
fun main() {
    // Int 에 대해 str을 매개변수로 받는 times라는 중위 표현식을 정의한다.
    infix fun Int.times(str: String) = str.repeat(this)
    println(2 times "Bye ")
    
    // 표준 라이브러리로 부터 'to'라는 중위 함수를 사용하여 pair를 만듬.
    val pair = "Ferrari" to "Katrina"
    println(pair)
    
    // onto라는 중위 함수를 커스텀하게 생성
    infix fun String.onto(other: String) = Pair(this, other)
    val myPair = "McLaren" onto "Lucas"
    println(myPair)
    
    val sophia = Person("Sophia")
    val claudia = Person("Claudia")
    // 중위 함수는 멤버 함수(메서드)에서도 작동한다.
    sophia likes claudia
    
}

class Person(val name: String) {
    val likedPeople = mutableListOf<Person>()
    infix fun likes(other: Person) { likedPeople.add(other) }
    
}
```

> Output
>
> ```
> Bye Bye 
> (Ferrari, Katrina)
> (McLaren, Lucas)
> ```

---

##### Operator Functions

* 연산자를 오버로드하려면 해당 함수를 `operator` 수정자로 표시한다.
  * 동일한 기능에 대해 operator, infix를 사용하지 못하는 건가..?

```kotlin
fun main() {
    // times()의 연산자 기호는 * 이므로 다음과 같이 사용 가능하다.
	operator fun Int.times(str: String) = str.repeat(this)
	println(2 * "Bye ")
    
    // 쉽게 연산자에 대해 범위 액세스하는 방법
    operator fun String.get(range: IntRange) = substring(range)
    val str = "Always forgive your enemies; nothing annoys them so much."
    println(str[0..14])
    
}
```

> Output
>
> ```
> Bye Bye 
> Always forgive
> ```

---

##### Functions with `vararg` Parameters

* `Varargs`를 사용하여 인수를 ','로 구분하여 원하는 수만큼 전달할 수 있다.

```kotlin

```

> Output
>
> ```
> 
> ```

---

