##### Servlet

* 클라이언트의 Request에 대해 동적으로 작동하는 웹 앱 컴포넌트

##### Servlet Container

* 웹 서버와의 통신 지원
  * 일반적으로 소켓을 만들고 listen, accept를 해야하지만, 컨테이너가 이러한 기능을 API로 제공하여 복잡한 과정을 생략. 개발자는 비즈니스 로직에 대해서만 초점을 두면 된다.

---

##### jsp

- Template Engine 중 성능이 가장 좋음
  ([동시성 수준이 25인 요청 25,000개를 처리하는 데 걸리는 총 시간](https://github.com/jreijn/spring-comparing-template-engines#benchmarks-102019))

* 서버에서 생성되는 페이지로 전체 페이지, DOM이 완료될 때 까지 기다려야하는 단점.
* 레거시 아니면 안 씀, 프론트 백이랑 분리되는 추세니까

---

* Servlet은 비즈니스 로직을 작성하고 유지보수하는데 편리하지만 view를 구현하기 불편하다. (Java 코드 안에 HTML 코드)
  * 이 단점을 보완하기 위해 만든 언어가 JSP

* JSP는 view를 구현하기 편하지만 비즈니스 로직을 작성하고 유지보수하는데 불편하다.

Model은 javaBean / View는 JSP / Controller는 Servlet 이었던 것

이러한 단점들을 개선하기 위해 등장한 디자인 패턴이 **MVC** 패턴

---

##### POJO

https://ko.wikipedia.org/wiki/Plain_Old_Java_Object

https://bobr2.tistory.com/entry/%EC%8A%A4%ED%94%84%EB%A7%81-%EC%A3%BC%EC%9A%94-%EA%B0%9C%EB%85%90-%EC%9A%A9%EC%96%B4-1-Beans-%EC%99%80-POJO
