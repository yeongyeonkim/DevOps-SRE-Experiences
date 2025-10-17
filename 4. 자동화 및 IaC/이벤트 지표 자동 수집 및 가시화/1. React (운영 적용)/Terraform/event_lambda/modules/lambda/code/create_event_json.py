import json
import boto3
import os
from datetime import datetime, timezone, timedelta
from urllib.parse import urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError
import logging

# 로깅 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def create_event_json(event, context):
    """
    Prometheus에서 12-13시 사이 Pod 개수와 평균 CPU 최대치를 조회하여 
    네임스페이스별로 평면 배열에 date별로 누적하는 Lambda 함수
    """
    
    # 환경 변수에서 설정 값 읽기
    prometheus_url = os.environ.get('PROMETHEUS_URL', 'http://prometheus-server:9090')
    s3_bucket = os.environ.get('S3_BUCKET_NAME')
    namespace_filter = os.environ.get('NAMESPACE_FILTER', 'default')
    json_file_key = os.environ.get('JSON_FILE_KEY', 'prometheus-metrics/daily-pod-metrics.json')
    
    if not s3_bucket:
        logger.error("S3_BUCKET_NAME 환경 변수가 설정되지 않았습니다.")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'S3_BUCKET_NAME 환경 변수가 필요합니다.'})
        }
    
    try:
        # 현재 시간이 12-13시 사이인지 확인
        current_time = datetime.now(timezone.utc)
        current_hour = current_time.hour
        
        # 12-13시가 아니면 경고 로그만 남기고 계속 진행 (테스트를 위해)
        if current_hour < 12 or current_hour >= 13:
            logger.warning(f"현재 시간 {current_hour}시는 수집 시간대(12-13시)가 아닙니다.")
        
        # 12-13시 사이의 Pod 메트릭 수집
        pod_metrics = collect_pod_metrics_for_timeframe(prometheus_url, namespace_filter)
        
        if not pod_metrics:
            logger.warning("수집된 메트릭 데이터가 없습니다.")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': '수집된 데이터가 없습니다.'})
            }
        
        # 기존 JSON 파일 읽기 또는 새로 생성
        existing_data = load_existing_json_from_s3(s3_bucket, json_file_key)
        
        # 오늘 데이터 추가
        today_date = current_time.strftime('%Y-%m-%d')
        updated_data = add_daily_metrics(existing_data, today_date, pod_metrics)
        
        # S3에 업데이트된 JSON 업로드
        upload_json_to_s3(s3_bucket, json_file_key, updated_data)
        
        logger.info(f"성공적으로 {len(pod_metrics['namespaces'])} 개의 네임스페이스 메트릭을 처리하고 JSON을 업데이트했습니다.")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'성공적으로 {today_date} 데이터를 추가했습니다.',
                'namespaces': list(pod_metrics['namespaces'].keys()),
                'total_namespaces': len(pod_metrics['namespaces']),
                'date': today_date,
                's3_key': json_file_key
            })
        }
        
    except Exception as e:
        logger.error(f"Lambda 함수 실행 중 오류 발생: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'내부 서버 오류: {str(e)}'})
        }

def collect_pod_metrics_for_timeframe(prometheus_url, namespace_filter):
    """
    12-13시 시간대의 네임스페이스별 Pod 개수와 평균 CPU 최대치를 수집
    """
    current_time = datetime.now(timezone.utc)
    
    # 12시부터 13시까지의 시간 범위 설정 (1시간)
    end_time = current_time
    start_time = current_time - timedelta(hours=1)
    
    # 네임스페이스별 Pod 개수 조회 쿼리
    pod_count_query = f"""
    count by (namespace) (
        sum by (namespace, pod) (
            node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{{
                namespace=~"{namespace_filter}"
            }}
        )
    )
    """
    
    # 네임스페이스별 CPU 사용률 최대치 조회 쿼리
    cpu_max_query = f"""
    max_over_time(
        (
            sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{{namespace=~"{namespace_filter}"}}) by (namespace, pod) / 
            sum(cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests{{namespace=~"{namespace_filter}"}}) by (namespace, pod) * 100
        )[1h:]
    )
    """
    
    try:
        # 네임스페이스별 Pod 개수 조회
        namespace_pod_counts = query_prometheus_by_namespace(prometheus_url, pod_count_query)
        logger.info(f"수집된 네임스페이스별 Pod 개수: {namespace_pod_counts}")
        
        # 네임스페이스별 CPU 최대치들 조회
        namespace_cpu_max = query_prometheus_cpu_by_namespace(prometheus_url, cpu_max_query)
        logger.info(f"수집된 네임스페이스별 CPU 최대치: {namespace_cpu_max}")
        
        # 네임스페이스별 데이터 통합
        namespace_metrics = {}
        all_namespaces = set(list(namespace_pod_counts.keys()) + list(namespace_cpu_max.keys()))
        
        for namespace in all_namespaces:
            pod_count = namespace_pod_counts.get(namespace, 0)
            cpu_values = namespace_cpu_max.get(namespace, [])
            avg_max_cpu = round(sum(cpu_values) / len(cpu_values), 2) if cpu_values else 0
            
            namespace_metrics[namespace] = {
                'pod_count': int(pod_count),
                'avg_max_cpu': avg_max_cpu
            }
            
        logger.info(f"처리된 네임스페이스: {list(namespace_metrics.keys())}")
        
        return {
            'namespaces': namespace_metrics,
            'collection_time': current_time.isoformat()
        }
        
    except Exception as e:
        logger.error(f"메트릭 수집 중 오류: {str(e)}")
        raise

def query_prometheus_by_namespace(prometheus_url, query):
    """
    Prometheus 쿼리로 네임스페이스별 Pod 개수 조회
    """
    params = urlencode({'query': query.strip()})
    url = f"{prometheus_url}/api/v1/query?{params}"
    
    logger.info(f"Prometheus 네임스페이스별 쿼리 실행: {url}")
    
    try:
        request = Request(url)
        request.add_header('User-Agent', 'AWS-Lambda-Prometheus-Collector')
        
        with urlopen(request, timeout=30) as response:
            if response.status != 200:
                raise HTTPError(url, response.status, f"HTTP {response.status}", response.headers, None)
            
            data = json.loads(response.read().decode('utf-8'))
        
        if data['status'] != 'success':
            logger.error(f"Prometheus 쿼리 실패: {data.get('error', 'Unknown error')}")
            return {}
        
        results = data['data']['result']
        namespace_counts = {}
        
        for result in results:
            namespace = result['metric'].get('namespace', 'unknown')
            count = float(result['value'][1])
            namespace_counts[namespace] = count
            
        logger.info(f"네임스페이스별 Pod 개수: {namespace_counts}")
        return namespace_counts
            
    except Exception as e:
        logger.error(f"네임스페이스별 쿼리 실행 중 오류: {str(e)}")
        return {}

def query_prometheus_cpu_by_namespace(prometheus_url, query):
    """
    Prometheus 범위 쿼리로 네임스페이스별 CPU 최대치 배열 조회
    """
    current_time = datetime.now(timezone.utc)
    end_time = current_time
    start_time = current_time - timedelta(hours=1)
    
    params = urlencode({
        'query': query.strip(),
        'start': start_time.isoformat(),
        'end': end_time.isoformat(),
        'step': '60s'  # 1분 간격
    })
    url = f"{prometheus_url}/api/v1/query_range?{params}"
    
    logger.info(f"Prometheus 네임스페이스별 CPU 범위 쿼리 실행: {url}")
    
    try:
        request = Request(url)
        request.add_header('User-Agent', 'AWS-Lambda-Prometheus-Collector')
        
        with urlopen(request, timeout=30) as response:
            if response.status != 200:
                raise HTTPError(url, response.status, f"HTTP {response.status}", response.headers, None)
            
            data = json.loads(response.read().decode('utf-8'))
        
        if data['status'] != 'success':
            logger.error(f"Prometheus 범위 쿼리 실패: {data.get('error', 'Unknown error')}")
            return {}
        
        results = data['data']['result']
        namespace_cpu_values = {}
        
        for result in results:
            namespace = result['metric'].get('namespace', 'unknown')
            values = result.get('values', [])
            
            cpu_values = []
            for timestamp, value in values:
                try:
                    cpu_values.append(float(value))
                except (ValueError, TypeError):
                    continue
            
            if namespace not in namespace_cpu_values:
                namespace_cpu_values[namespace] = []
            namespace_cpu_values[namespace].extend(cpu_values)
        
        logger.info(f"네임스페이스별 CPU 값 개수: {[(ns, len(vals)) for ns, vals in namespace_cpu_values.items()]}")
        return namespace_cpu_values
        
    except Exception as e:
        logger.error(f"네임스페이스별 CPU 범위 쿼리 실행 중 오류: {str(e)}")
        return {}

def load_existing_json_from_s3(bucket_name, key):
    """
    S3에서 기존 JSON 파일 로드 (평면 배열 구조)
    """
    s3_client = boto3.client('s3')
    
    try:
        logger.info(f"기존 JSON 파일 로드 시도: s3://{bucket_name}/{key}")
        response = s3_client.get_object(Bucket=bucket_name, Key=key)
        existing_data = json.loads(response['Body'].read().decode('utf-8'))
        logger.info("기존 데이터 로드 성공")
        return existing_data
        
    except s3_client.exceptions.NoSuchKey:
        logger.info("기존 파일이 없어 새로 생성합니다.")
        return []
    except Exception as e:
        logger.error(f"기존 파일 로드 중 오류: {str(e)}")
        # 오류 시에도 새로운 구조로 시작
        return []

def add_daily_metrics(existing_data, date, pod_metrics):
    """
    기존 데이터에 오늘 날짜의 네임스페이스별 메트릭을 평면 배열로 추가
    """
    # 해당 날짜의 기존 데이터 제거 (업데이트를 위해)
    existing_data = [item for item in existing_data if item.get('date') != date]
    
    # 새로운 네임스페이스별 데이터 추가
    for namespace, metrics in pod_metrics['namespaces'].items():
        new_entry = {
            'date': date,
            'namespace': namespace,
            'pod_count': metrics['pod_count'],
            'avg_max_cpu': metrics['avg_max_cpu']
        }
        existing_data.append(new_entry)
    
    # 날짜와 네임스페이스 순으로 정렬
    existing_data.sort(key=lambda x: (x['date'], x['namespace']))
    
    logger.info(f"{date} 날짜에 {len(pod_metrics['namespaces'])}개 네임스페이스 데이터 추가 완료")
    
    return existing_data

def upload_json_to_s3(bucket_name, key, data):
    """
    업데이트된 JSON 데이터를 S3에 업로드
    """
    s3_client = boto3.client('s3')
    
    try:
        s3_client.put_object(
            Bucket=bucket_name,
            Key=key,
            Body=json.dumps(data, indent=2, separators=(',', ': '), ensure_ascii=False),
            ContentType='application/json'
        )
        logger.info(f"S3 업로드 완료: s3://{bucket_name}/{key}")
        
    except Exception as e:
        logger.error(f"S3 업로드 실패: {str(e)}")
        raise

# 로컬 테스트용 함수
if __name__ == "__main__":
    test_event = {}
    test_context = {}
    
    # 테스트 환경 변수 설정
    os.environ['PROMETHEUS_URL'] = 'http://localhost:9090'
    os.environ['S3_BUCKET_NAME'] = 'your-metrics-bucket'
    os.environ['NAMESPACE_FILTER'] = 'admin|test'  # 네임스페이스 예시
    os.environ['JSON_FILE_KEY'] = 'prometheus-metrics/daily-pod-metrics.json'
    
    result = lambda_handler(test_event, test_context)
    print(json.dumps(result, indent=2))