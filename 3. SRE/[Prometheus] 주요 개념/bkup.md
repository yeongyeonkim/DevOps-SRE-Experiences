### 목적

프로메테우스의 주요 개념들을 파악한다.
이후, 실제 프로젝트에서 운영되는 프로메테우스를 개선하고
추가로 Thanos를 구성하도록 한다.

#### 주요 개념

#### 시계열(Time Series)

 * 프로메테우스의 모든 데이터는 시계열 형태로 저장된다.
  즉, <b>시간</b>과 <b>값</b>의 쌍으로 구성되며, metric(수집 대상) + label(메타데이터) 조합이 완전히 동일하면 같은 시계열로 간주한다.
  ```
  http_requests_total{method="GET", status="200", endpoint="/"} -> 하나의 시계열
  http_requests_total{method="POST", status="500", endpoint="/login"} -> 또 다른 시계열
  ```
  따라서, 시계열의 개수는 <b>고유한 metric + label 조합의 수</b> 이다.

  * 전체 시계열 수 확인
    `$ prometheus_tsdb_head_series`: 현재 메모리에 적재된 시계열 수
	![timeseriescount](img/timeseriescount.png)
	
  * 메트릭별 시계열 수 확인(top 20)
    `$ topk(20, count by (__name__)({__name__!=""}))`
	![timeseriesbymetrics](img/timeseriesbymetrics.png)

#### Cardinality

 * 유니크한 시계열의 개수(데이터의 고유한 값의 개수)
  같은 메트릭이라도 label 값이 많을수록 시계열이 늘어나게된다.
  ```
  metrics_name{pod="pod1", status="200"}
  metrics_name{pod="pod2", status="200"}
  metrics_name{pod="pod3", status="500"}
  ```
  위와 같은 경우, Cardinality가 3이다.

#### Cardinality 개선 방법
 
 1. Label 최소화
    * 불필요한 label 제거
 2. Exporter 설정 조정
    * node_exporter, kube-state-metircs 등에서 불필요한 metric 수집 비활성화
 3. Relabeling 사용
    * scrpae 단계에서 필요 없는 label 제거 `metric_relabel_configs` 활용
 4. Recording Rule 적용
    * 자주 사용하는 쿼리는 사전에 집계하여 label 조합 단순화 (rate() -> record)


 먼저, 우리 프로젝트의 TSDB의 다양한 카디널리티 관련 통계치를 확인한다.(/api/v1/status/tsdb)
 ![prometheustsdb](img/prometheustsdb.png)
   * headState.numSeries: 시계열 개수
   * seriesCountByMetricName
   * labelValueCountByLabelName
   * memoryInBytesByLabelName
   * seriesCountByLabelValuePair

#### Memory
 프로메테우스 메모리는 주로 Cardinality 와 Ingestion 메모리로 이루어져있음.
 때문에 메모리 사용량이 높은 경우, 데이터 수집량이 많거나 label cardinality 가능성을 확인한다.
 
 1. Cardinality Memory
  - 얼마나 많은 종류의 시계열이 있는가
  저장하는 것: 시계열의 메타데이터(Label 정보)
  예시
  ```
  http_requests_total{job="api", instance="server1", method="GET"}
  http_requests_total{job="api", instance="server2", method="POST"}
  ```
  특징: 시계열 수와 Label이 많을수록 증가한다.

 2. Ingestion Memory
  - 얼마나 자주, 얼마나 많은 데이터를 수집하는가
  저장하는 것: 실제 데이터 포인트(숫자 값 + 타임스탬프), Scrape로 수집한 샘플들
  예시
  ```
  # Scrape가 15초인 경우
  15:00:00 -> 값: 100
  15:00:15 -> 값: 105
  15:00:30 -> 값: 108
  ```
  특징: 시간이 지나면 안축되고 디스크로 이동



 ※ 참고 사이트: https://www.robustperception.io/how-much-ram-does-prometheus-2-x-need-for-cardinality-and-ingestion/


#### 
1. 자원 사용량 관점

 - Storage (PVC) 사용량
   ![prometheusdisk](img/prometheusdisk.png)
 * 디스크 포화의 경우, retention 기간이 길거나, scrape interval이 짧을 수 있음

2. 메트릭 수집량



3. 저장소 및 보존 주기(retention) 설정 확인
 
 ```
 $ kubectl get sts -n monitoring prometheus-kube-prometheus-stack-prometheus -o yaml | grep retention
        - --storage.tsdb.retention.time=7d
        - --storage.tsdb.retention.size=25GiB
 ```

 * 보존 기간이 길면 로컬 디스크 감당이 되지 않기 때문에 Thanos의 Object Storage 백엔드가 필요해진다.
 * PVC가 local stroage면 노드 장애 시 데이터 유실 리스크가 존재 -> Thanos로 이중화
