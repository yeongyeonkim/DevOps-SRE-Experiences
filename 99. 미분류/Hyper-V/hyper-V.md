# Hyper-V

### hyper-v 활성화

* Window OS에서 하드웨어를 가상화하고 **가상 컴퓨터(가상 머신)**을 만들고 OS를 설치하여 호스트 OS에서 여러 OS를 동작시키는 기능.
* Window 10 Pro 버전임을 확인.

![2](img/2.png)

* PowerShell을 관리자 권한으로 실행하여 **명령어** 입력 후 Hyper-V 사용하도록 설정.
* Windows 기능에서 Hyper-V 역할 활성화.

![3](img/3.PNG)

-----

### image Download

![iso](img/iso.png)

* CentOS 7부터 2세대를 지원 (Linux : 2 Gen, 2 Mem, Disk 20GB)

----

### Linux 가상 컴퓨터 생성

![4_hyper-v_빨리만들기](img/4_hyper-v_빨리만들기.PNG)

![5](img/5.PNG)

![6. 이름](img/6.이름.PNG)



![7. 세대](img/7.세대.PNG)



![8.메모리](img/8.메모리.PNG)



![9.네트워크어댑터](img/9.네트워크어댑터.PNG)



![10.크기](img/10.크기.PNG)

![11](img/11.PNG)

![12. 오류](img/12-1.오류.PNG)

* Centos 7 - pxe start over ipv4 오류
* Hyper-V 관리자 - [설정] - [보안] 탭 - [보안 부팅 사용] 체크 해제 혹은 **UEFI **템플릿 설정.
  ※ 보안 부팅 : 권한 없는 펌웨어, OS가 부팅 시 실행되지 않도록 함. -> 오류 유발하므로 해제.
  2세대에서는 기본적으로 활성화되어 있다.

![12](img/12.PNG)![13](img/13.PNG)
