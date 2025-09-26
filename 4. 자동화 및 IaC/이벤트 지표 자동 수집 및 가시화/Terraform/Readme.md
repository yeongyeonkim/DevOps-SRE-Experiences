1. 이벤트 메트릭 수집
 - 매일 15시 점심 피크 때의 CPU 지표를 Prometheus 서버로부터 데이터를 가져와서 json 형식으로 S3에 저장한다.

2. 이벤트 메트릭 표현
 2-1. Grafana infinity
   'Grafana infinity - API GW - Lambda - S3' 연결을 통해서 json 형식의 파일을 대시보드로 표현한다.
 2-2. React
   json 형식의 파일을 React 반응형 페이지로 보여준다.