##### @Entity

* JPA를 사용해서 테이블과 매핑할 클래스를 지정한다.
  - name 엔티티 이름을 지정 / 디폴트 : 클래스 이름을 그대로 사용.
    ex) @Entity(name = " ")

##### @Table

* 엔티티와 매핑할 테이블을 지정한다. 생략하면 매핑한 엔티티 이름을 테이블 이름으로 사용한다.

##### @Id

* 기본키(primary key) 매핑.

##### @Column

* 테이블의 컬럼명 매핑. 지정 안하는 경우 객체 필드명과 동일하게 지정.

##### @Enumerated

* 자바의 enum 타입을 사용하는 경우 지정

##### @Temporal

* 날짜 타입(Data, Calendar) 매핑시 사용(DATE, TIME, TIMESTAMP).

##### @Lob

* CLOB, BLOB 타입과 매핑.

##### @Transient

* 테이블 컬럼에 매핑되지 않는 필드에 지정.

##### @Access

* JPA가 엔티티 데이터에 접근하는 방식 지정. FIELD가 기본값. 필드(FIELD) or Getter(PROPERTY).