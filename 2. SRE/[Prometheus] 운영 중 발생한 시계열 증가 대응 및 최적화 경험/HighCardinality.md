### 개선 포인트

개선 포인트에는 크게 아래 방법들이 존재하는 것 같다.

* Recording Rules 사용
* Label 설계 최적화
* Relabeling 설정
* 보관 기간 조정
* Thanos를 통해 장기 저장 및 다중 Prometheus 통합

#### Recording Rules 적용

#### Label 설계 최적화

![bucket](cardinality/http_server_requests_seconds_bucket.png)

17개의 서비스가 Actuator를 통해 `http_server_requests_seconds_bucket` 시계열을 모두 노출하고 있기 때문에 1만5천 개가 넘는 시계열이 생겼다.
이것을 최적화하자.

시계열 하나는 아래와 같은 형식이다. 여기서 불필요한 라벨을 제거하거나 최소화하자.
`http_server_requests_seconds_bucket{application="test", container="test-release", endpoint="http", error="none", exception="none", instance="172.110.5.115:8080", job="a-test", le="1.0", method="GET", namespace="test", outcome="SUCCESS", pod="a-test-776f88f485-l5rmx", service="a-test", status="200", uri="/test/healthcheck"}`

* slo 설정 최소화
  `/config/application/management.metrics.distribution.slo.http.server.requests` 값 조정을 통해 
  무분별한 le 구간을 줄여서 시계열 수를 감소시킬 수 있게 된다.

1. `topk(20, count by(__name__)({__name__!=""}))`
 
 * 현재 Prometheus에 저장된 메트릭 이름 단위로 시계열이 몇 개 존재하는지를 보여준다.