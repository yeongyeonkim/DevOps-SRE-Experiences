##### 0. DI

> 객체를 직접 생성하지 않고 외부에서 생성한 후 주입

* 동작 과정
  1. 생성자 주입
     * Bean 등록과 동시에 DI (Bean 등록 시 생성자가 호출되므로)
  2. 필드 주입 + Setter 주입
     * 스프링 컨테이너에 스프링 Bean 모두 등록
     * 빈 관계 설정(연관관계 주입)

##### 1. 생성자 주입 (★)

```java
@Component
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    
    @Autowired //
    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

* 생성자가 하나면 `@Autowired` 생략 가능

```java
@Component
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    
//    @Autowired
//    public UserServiceImpl(UserRepository userRepository) {
//        this.userRepository = userRepository;
//    }
}
```

* Lombok 사용하는 경우 `@RequiredArgsConstructor` 를 사용하여 final 키워드가 붙은 필드에 대한 생성자를 자동 생성

---

##### 2. 필드 주입

```java
@Component
public class UserServiceImpl implements UserService {
    @Autowired
    private UserRepository userRepository;
}
```

* 불변성, 순환 참조 컴파일 에러 등 문제를 유발할 수 있다.



---

##### 3. Setter 주입

```java
@Component
public class UserServiceImpl implements UserService {
    private UserRepository userRepository;
    
    @Autowired
    public void setUserRepository(UserRepository userRepository) {
 		this.userRepository = userRepository;   	
    }
}
```

* set + 필드명

---

참고: https://velog.io/@znftm97/Spring-DIDependency-Injection-%EC%A0%95%EB%A6%AC