1. Terraform
 - Lambda
  이벤트 메트릭 수집 (cloudwatch, prometheus api ..)
  이벤트 메트릭 가져오기(get s3 object)
 - EventBridge
  매일 15시마다 이벤트 메트릭을 수집을 트리거
 - API GW
  여러 시스템 지표들(Pod, RDS ..)에 대한 Lambda가 존재하고 이 Lambda들을 API GW의 Stage를 통해 쉽게 분리하여(/prod/pod, /prod/rds ..)
  단일 지점에 대한 요청으로 관리에 용이하다

2. 이벤트 메트릭 수집
 - 매일 15시 점심 피크 때의 CPU 지표를 Prometheus 서버로부터 데이터를 가져와서 json 형식으로 S3에 저장한다.

3. 이벤트 메트릭 표현
 2-1. Grafana infinity
   'Grafana infinity - API GW - Lambda - S3' 연결을 통해서 json 형식의 파일을 대시보드로 표현한다.
 2-2. React
   json 형식의 파일을  페이지로 보여준다.
   