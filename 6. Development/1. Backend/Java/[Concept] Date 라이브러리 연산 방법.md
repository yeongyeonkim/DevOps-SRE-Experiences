##### Date에 하루를 추가하고 빼는 방법

* `plusDays` , `minusDays` 메소드

  - Java 1.8 이후 `java.time` 의 `LocalDate` , `LocalDateTime` 클래스에 추가되었다.

  ``` java
  import java.time.LocalDateTime;
  
  public class LocalDateTimeTest {
      public static void main(String[] args) {
          LocalDateTime yesterday = LocalDateTime.now().minusDays(1);
          LocalDateTime today = LocalDateTime.now();
          LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
          System.out.println("어제 : " + yesterday);
          System.out.println("오늘 : " + today);
          System.out.println("내일 : " + tomorrow);
      }
  }
  
  /*
  어제 : 2022-06-06T17:23:27.411462400
  오늘 : 2022-06-07T17:23:27.412462800
  내일 : 2022-06-08T17:23:27.412462800
  */
  ```

* `Calendar` 메소드

  ```java
  import java.util.Calendar;
  import java.util.Date;
  
  public class CalendarTest {
  
  	public static void main(String[] args) {
  		Date date = new Date();
  		System.out.println("오늘 : " + date);
  		Calendar calendar = Calendar.getInstance();
  		calendar.setTime(date);
  		calendar.add(Calendar.DATE, 1);
  		date = calendar.getTime();
  		System.out.println("내일 : " + date);
  	}
  
  }
  
  /*
  오늘 : Tue Jun 07 17:31:54 KST 2022
  내일 : Wed Jun 08 17:31:54 KST 2022
  */
  ```

* 이외에도 `Milliseconds`, `Instant` 등 다양한 클래스를 활용 가능하다.