##### RestTemplate

* 복잡한 HttpClient 사용을 한번 추상화한 객체로써 단순 메소드 호출만으로 쉽게 HTTP 요청을 주고 받을 수 있도록 도와준다

##### TestRestTemplate

* REST 방식으로 개발한 API Test를 최적화하기 위한 클래스

##### RestTemplate 특징

* RESTful
* 멀티쓰레드 방식
* Thread Safe
  * 따라서, 경쟁 상태가 발생하지 않아서 전역변수로 사용해도 된다. 

* Blocking 방식

##### RestTemplate 메소드

https://hoonmaro.tistory.com/46#resttemplate-methods

* exchange
  * HTTP 메서드, URL, 헤더 및 본문을 포함한 RequestEntity를 입력받아 ResponseEntity를 Return

##### RestTemplate 작동 순서

<img src="img/RestTemplate.png" alt="RestTemplate" style="zoom:73%;" />

1. 어플리케이션이 RestTemplate를 생성하고, URI, HTTP메소드 등의 헤더를 담아 요청한다.
2. RestTemplate 는 HttpMessageConverter 를 사용하여 requestEntity 를 요청메세지로 변환한다.
3. RestTemplate 는 ClientHttpRequestFactory 로 부터 ClientHttpRequest 를 가져와서 요청을 보낸다.
4. ClientHttpRequest 는 요청메세지를 만들어 HTTP 프로토콜을 통해 서버와 통신한다.
5. RestTemplate 는 ResponseErrorHandler 로 오류를 확인하고 있다면 처리로직을 태운다.
6. ResponseErrorHandler 는 오류가 있다면 ClientHttpResponse 에서 응답데이터를 가져와서 처리한다.
7. RestTemplate 는 HttpMessageConverter 를 이용해서 응답메세지를 java object(Class responseType) 로 변환한다.
8. 어플리케이션에 반환된다.

##### RestTemplate 사용

* RestTemplate은 기본 생성자 `new RestTemplate()` 외에 [ClientHttpRequestFactory](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/http/client/ClientHttpRequestFactory.html) 인터페이스를 받는 생성자가 있다. 여러 구현체 중 `SimpleClientHttpRequestFactory` 와 `HttpComponentsClientHttpRequestFactory`가 대표적인 구현체이다.

  * SimpleClientHttpRequestFactory

    * 별도의 인자 없이 RestTemplate을 생성하게 됬을 경우, 이 구현체를 사용하게 되고 HttpUrlConnection을 이용한다. Connection Pool 등 여러 속성이 지원되지 않음.

  * HttpComponentsClientHttpRequestFactory

    * Connection pool을 적용하기 위한 구현체, HttpClient 라이브러리를 이용하여 구현되어 있다. HttpClient는 HttpUrlConnection에 비해 모든 응답코드를 읽을 수 있고 Time-out 설정과 쿠키 제어가 가능하다.

    ```java
    @Configuration
    public class RestTemplateConfig {
        @Bean
        CloseableHttpClient httpClient() {
            return HttpClientBuilder.create()
                    .setMaxConnTotal(60) // 최대 Connection 수
                    .setMaxConnPerRoute(3) // IP/Domain name 당 최대 Connection 수
                    .build();
        }
    
        @Bean
        HttpComponentsClientHttpRequestFactory factory(CloseableHttpClient closeableHttpClient) {
            HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
            factory.setReadTimeout(5000);        // 읽기시간초과(ms)
            factory.setConnectTimeout(3000);     // 연결시간초과(ms)
            factory.setHttpClient(closeableHttpClient);
    
            return factory;
        }
        @Bean
        RestTemplate restTemplate(HttpComponentsClientHttpRequestFactory factory) {
            return new RestTemplate(factory);
        }
    }
    
    ```

##### RestTemplate Connection issue

* RestTemplate은 호출할 때마다, 로컬에서 임시 TCP 소켓을 개방하여 사용한다. 이렇게 사용된 TCP 소켓은 TIME_WAIT 상태가 되는데, 요청량이 많아진다면 TIME_WAIT 상태의 소켓들은 재사용 될 수 없기 때문에 응답에 지연이 생길 수 있다. 
* 이러한 응답 지연 상황을 대비하여 DB가 Connection Pool을 이용하듯이 RestTemplate도 Connection Pool을 이용할 수 있다. 그러기 위해선 RestTemplate 내부 구성을 설정해야 한다.
  * 단, 호출하는 API 서버가 Keep-Alive를 지원해야 한다. 
    * 대상 서버가 Keep-Alive를 지원하지 않으면, 미리 Connection Pool을 만들어 놓지 못하고 요청마다 새로운 Connection이 연결되어 매번 handshake가 발생되어 RestTemplate의 Connection Pool을 위한 내부 설정이 의미가 없어지기 때문.

##### Message Converter

https://hoonmaro.tistory.com/46#httpmessageconverter-%EA%B5%AC%ED%98%84%EC%B2%B4-%EB%AA%A9%EB%A1%9D

* FormHttpMessageConverter
  * HTTP 요청 및 응답으로부터 form 데이터를 읽고 쓸 수 있는 구현체
    기본적으로 `application/x-www-form-urlencoded` 미디어 타입을 지원한다.
    Form 데이터는 `MultiValueMap<String, String>` 형식
* MappingJackson2HttpMessageConverter
  * Jackson 라이브러리의 `ObjectMapper`를 사용하여 JSON을 읽고 쓸 수 있는 구현체
    JSON 매핑은 필요에 따라 Jackson이 제공하는 어노테이션을 통해 커스터마이징 될 수 있다.
    추가 제어가 필요할 경우 특히, 특정 유형에 대해 커스텀 JSON 직렬화/역직렬화를 제공해야 하는 경우 ObjectMapper 속성을 통해 커스텀 ObjectMapper를 주입할 수 있다.
    기본적으로 `application/json`을 지원한다.
