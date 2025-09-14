Linux 및 Windows Server 설치하기

* **구성요소**

  * Hyper-V 이용하여 가상화 설치

  - Linux / Windows Images Download 하여 OS 설치 (Linux : CentOS 6 권장 / Windows 2008R2 이상 권장)

  1. Linux : 2 Core / 2 Mem / Disk 20GB

  2. Windows : 2 Core / 2MEM / Disk 30GB


  - 각각 설치 이후 Network 연결하여 SSH 및 RDP 접속 할 수 있도록 설정

* **기본설정**
  * <u>Linux</u>
    1. Root Login 중지
    2. User 계정 생성 이후 Root 접근 허용
    3. 시간동기화 매일 설정
    4. Syslog 통합
    5. DNS 설정
    6. 불필요한 서비스 비활성화
    7. SSH 접속 설정
  * <u>Windows</u>
    1. 원격접속 설정

- **Application 설정**
  - <u>Linux</u>
    1. Apache + PHP + MySQL 컴파일 설치
    2. WEB Page phpinfo 화면 출력
    3. MySQL 접속하여 DB 호출 화면 출력
    4. ftp 설치하여 FTP 구동 화면
  - <u>Windows</u>
    1. IIS + PHP(FastCGI) 연동
    2. ftp 설치하여 FTP 구동 화면

* **방화벽 설정**
  * 특정 IP 에서만 SSH, RDP, HTTP 접근 할 수 있도록 설정 (그 외에 다른 IP에서는 모두 차단)