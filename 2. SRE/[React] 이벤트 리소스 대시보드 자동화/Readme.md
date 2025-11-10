## 📊 관련 문서
 
 ![ResourceDashboardArchitecture.png](img/ResourceDashboardArchitecture.png)

 **[이벤트 지표 자동 수집 및 가시화](https://github.com/yeongyeonkim/ALL/tree/main/4.%20%EC%9E%90%EB%8F%99%ED%99%94%20%EB%B0%8F%20IaC/%EC%9D%B4%EB%B2%A4%ED%8A%B8%20%EC%A7%80%ED%91%9C%20%EC%9E%90%EB%8F%99%20%EC%88%98%EC%A7%91%20%EB%B0%8F%20%EA%B0%80%EC%8B%9C%ED%99%94)** 문서와 연관있습니다.
 

### 목적

* 트래픽이 유입되는 주요 시간(오전/점심 피크) 1시간 가량 중 리소스 사용량을 분석한다.

### 사용한 쿼리

#### Pod

1. Pod 개수

* CPU와 같이 max_over_time [1h:] 윈도우를 설정하면 그렇지 않은 것 보다 부정확한 값이 나와 사용하지 않았다.

```
    count by (namespace) (
        sum by (namespace, pod) (
           node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{namespace=~"{namespace_filter}"}
        )
    )
```

2. Pod CPU(컨테이너별)
```
    max_over_time(
        (
            sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{{namespace=~"{namespace_filter}"}}) by (namespace, pod)
            /
            sum(cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests{{namespace=~"{namespace_filter}"}}) by (namespace, pod)
            * 100
        )[1h:]
    )
```

3. Pod CPU(Namespace별)
```
    max_over_time(
        (
            sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{{namespace=~"{namespace_filter}"}}) by (namespace)
            /
            sum(cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests{{namespace=~"{namespace_filter}"}}) by (namespace)
            * 100
        )[1h:]
    )
```

※ 위 2, 3번의 차이는 by (namespace, pod), by (namespace) 이다.
2번은 컨테이너는 순간의 Spike 까지 잡아내어 그 지표를 보여주기 때문에 좀 더 변동성있는 그래프가 될 것이고
3번은 namespace 내 cpu 평균을 취합해서 그 중의 최대이기 때문에 상대적으로 완만할 것이다.
