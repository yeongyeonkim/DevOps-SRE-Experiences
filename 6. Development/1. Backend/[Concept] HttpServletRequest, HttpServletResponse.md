##### WAS가 브라우저로 부터 Servlet 요청을 받는다.

* HttpServletRequest 객체를 생성하여 전달 받은 정보를 저장.

* HttpServletResponse 빈 객체를 생성

* 두 객체를 Servlet에게 전달

##### HttpServletRequest

* Http 프로토콜의 request 정보를 Servlet에게 전달하기 위한 목적
* Header 정보, Parameter, Cookie, URI, URL 등의 정보를 읽어들이는 메소드를 가진 클래스
* Body의 Stream을 읽어들이는 메소드를 가지고 있다

##### HttpServletResponse

* Servlet은 HttpServletResponse 객체에 Content Type, 응답코드, 응답 메시지 등을 담아서 전송

