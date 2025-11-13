##### tail

AWS System Manager를 사용하거나 서버에 터미널하여 접속 한 후

`tail -f /{log path}.2022-06-29.log | grep -i "Exception"` 처럼 대소문자 구별 없이 실시간으로 검색하는 방법을 사용하였다.

---

##### Cloud Watch

그런데, 터미널이 막히고 System Manager로 접근 시 서버 자체에 Timeout이 걸려있는 경우 세션이 종료되어 그때마다 접속해야하는 불편함이 생겨

서버에 Cloud Watch agent를 설치하고, Cloud Watch - '로그' - '로그 그룹' 에서 `EXCEPTION` 으로 검색되는지 주기적으로 눌러서 확인하는 것으로 하였다. (대소![cloud watch](C:\ALL\Backend\img\cloud watch.png)문자를 주의해서 검색해야 함)

---

##### Watch

하지만 주기적으로 클릭하는 것도 번거롭기 때문에 linux의 watch 명령어를 사용하여

timeout에도 걸리지 않고 따로 새로고침이나 명령어를 다시 입력하지 않아도 Exception을 잡아주도록 하였다

`watch "grep -i 'exception' /{log_path}.2022-06-29.log"`