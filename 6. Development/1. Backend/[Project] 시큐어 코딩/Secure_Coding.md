[취약점 항목]

SQL Injection
- 외부 입력이나 외부 변수로부터 받은 값이 직접 SQL 함수의 인자로 전달 금지
- 외부 인자 값은 prepareStatement 클래스와 하위 메소드 setString을 통해 외부 인자 값을 사용
- 외부 입력 값의 금지 문자 필터링 수행 (and, or, =, union)
- stmt.setString(1, tableName); 처럼 preparedStatement 클래스를 사용해 setString() 해서
외부의 입력이 쿼리의 구조를 바꾸는 것을 방지해야 한다.

개행 문자
- 개행 문자가 포함되면 HTTP 응답이 2개 이상으로 분리 위험이 존재
- replaceAll("\r", ""), replace("\n", "")으로 개행 문자 제거

getMessage 사용
- 에러 메시지는 유용한 최소한의 정보가 포함되도록 코딩
- e.g., System.err.print(e.getMessage()); ==> logger.error("IOException Occured");

부적절한 자원 해제
- 자원을 획득하여 사용한 다음에는 (예외의 발생 여부와 상관 없이) finally 블록에서 할당 받은 자원 반환 코딩

리소스에 대한 동시 사용
- 공유자원(e.g, 파일)을 여러 스레드가 접근하여 사용할 경우, 동기화 구문을 이용하여
한번에 하나의 스레드만 접근 하도록 코딩
-> 병렬 시스템(멀티 프로세스로 구현한 응용프로그램)에서는 자원(파일, 소켓)을 사용하기에 앞서
자원의 상태를 검사하게 되는데, 사용하는 시점이 검사 시점과 다르기 때문에 
검사 시점에 존재하던 자원이 사용하는 시점에 사라지는 등 자원의 상태가 변하는 경우가 생기면
보안 취약점이 발생하게 된다.
-> synchronized 사용 (https://m.blog.naver.com/gs_info/221575045619) 혹은 mutex
동기화 구문을 사용하여 한 번에 하나의 프로세스만 접근 가능하도록, 
또한 성능에 미치는 영향을 최소화하기 위해 임계코드 주변만 동기화 구문을 사용하도록 해야 한다.

하드코드 된 패스워드
- 프로그램 소스 내에 하드 코딩된 패스워드 포함 금지
e.g., 
String key = "22df3023sf~2;asn!@#/>as";
=> String key = getpassword("./password.ini");  key = decrypt(key);
로 수정
