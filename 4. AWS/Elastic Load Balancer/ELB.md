#### ALB

* OSI 7 계층의 특성을 이용하는 로드밸런서. 그 중에서도 HTTP, HTTPS의 특성을 주로 다룬다.
* HTTP의 헤더 정보를 이용해 부하분산을 실시한다.
* path-based(경로 기반) 라우팅이 지원된다.
* SSL 인증서를 탑재할 수 있어 탑재 그룹의 EC2를 대신하여 SSL 암호화/복호화를 대신 진행

#### NLB

* OSI 4 계층의 특성을 이용하는 로드밸런서. TCP/UDP
* 로드밸런서에 대한 **고정 IP, 탄력 IP** 주소 지원
* 인터넷 경계(External) - 인터넷을 통해 클라이언트 요청을 대상으로 라우팅한다. 퍼블릭 서브넷 필요.
* 내부(Internal) - 프라이빗 IP 주소를 사용하여 클라이언트 요청을 대상으로 라우팅한다.

#### Global Accelerator

(https://aws.amazon.com/ko/blogs/korea/using-static-ip-addresses-for-application-load-balancers/)

* Global Accelerator를 사용하여 ALB, NLB 또는 EC2 인스턴스와 같은 단일 또는 여러 AWS 리전에서 애플리케이션 엔드 포인트에 대한 고정 진입점 역할을 하는 고정 IP 주소를 얻을 수 있다.
* 클라이언트는 DNS 주소를 해석하여 ALB를 이용하여 문제없이 연결할 수 있다. 
  하지만, ALB의 IP 주소목록은 추가되거나 변경될 수 있어서 까다롭다. 고정 IP가 이를 해결해준다.
  또한 NLB는 고정 IP를 사용할 수 있지만 TCP 통신만 허용하기 때문에 HTTPS를 처리하지 않는다.
* ALB, NLB의 이점 중 하나만을 선택해야했던 것에서 두 가지 장점을 모두 가지는 방법으로 Global Accelerator가 나왔다.