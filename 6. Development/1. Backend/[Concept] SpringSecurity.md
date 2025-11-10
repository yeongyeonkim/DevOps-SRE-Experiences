### Spring Security

* 스프링에서는 인증 및 권한 부여를 통해 리소스의 사용을 쉽게 컨트롤할 수 있는 Spring Security 프레임워크를 제공한다.
* Spring의 Dispatcher Servlet 앞단에 Filter를 등록시켜 요청을 가로챈다. 클라이언트에게 리소스 접근 권한이 없을 경우 인증 화면(e.g., 로그인)으로 자동으로 리다이렉트 된다.
  * User - Security Filters - Spring Dispatcher Servlet - Spring Controller - Security Filters - User



