#!/bin/bash
# Grafana API 접근 설정
GRAFANA_URL=$GRAFANA_URL
SA_TOKEN=$SA_TOKEN

# 출력 디렉토리 (없으면 생성)
DATE_SUFFIX=$(date +%m%d)
OUTPUT_DIR="./grafana_dashboards_${DATE_SUFFIX}"
mkdir -p "$OUTPUT_DIR"

echo "Grafana 대시보드 내보내기 시작..."

# 모든 대시보드 목록 가져오기 (에러 체크 포함)
dashboard_list=$(curl -s -H "Authorization: Bearer $SA_TOKEN" \
    "$GRAFANA_URL/api/search?query=&type=dash-db")

if [ $? -ne 0 ] || [ -z "$dashboard_list" ]; then
    echo "오류: 대시보드 목록을 가져올 수 없습니다."
    exit 1
fi

# 대시보드 개수 확인
total_count=$(echo "$dashboard_list" | jq '. | length')
echo "총 $total_count 개의 대시보드를 발견했습니다."

# 카운터 초기화
exported_count=0
failed_count=0

# 각 대시보드 처리
echo "$dashboard_list" | jq -r '.[] | @base64' | while IFS= read -r dashboard_info; do
    # base64 디코딩하여 대시보드 정보 추출
    dashboard_data=$(echo "$dashboard_info" | base64 -d)
    uid=$(echo "$dashboard_data" | jq -r '.uid')
    title=$(echo "$dashboard_data" | jq -r '.title' | sed 's/[^a-zA-Z0-9가-힣_-]/_/g')
    
    if [ "$uid" = "null" ] || [ -z "$uid" ]; then
        echo "경고: UID가 없는 대시보드를 건너뜁니다: $title"
        continue
    fi
    
    echo "내보내는 중: [$uid] $title"
    
    # 대시보드 상세 정보 가져오기
    dashboard_json=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $SA_TOKEN" \
        "$GRAFANA_URL/api/dashboards/uid/$uid")
    
    # HTTP 상태 코드 확인
    http_code="${dashboard_json: -3}"
    response_body="${dashboard_json%???}"
    
    if [ "$http_code" = "200" ]; then
        # 대시보드 JSON 추출 및 저장
        dashboard_content=$(echo "$response_body" | jq '.dashboard')
        
        if [ "$dashboard_content" != "null" ] && [ -n "$dashboard_content" ]; then
            # 파일명: UID_제목.json 형태로 저장
            filename="${uid}_${title}.json"
            echo "$dashboard_content" > "$OUTPUT_DIR/$filename"
            
            # 파일이 제대로 저장되었는지 확인
            if [ -s "$OUTPUT_DIR/$filename" ]; then
                echo "✓ 성공적으로 저장됨: $filename"
                ((exported_count++))
            else
                echo "✗ 파일 저장 실패: $filename"
                ((failed_count++))
            fi
        else
            echo "✗ 대시보드 내용이 비어있음: $uid"
            ((failed_count++))
        fi
    else
        echo "✗ API 호출 실패 (HTTP $http_code): $uid"
        ((failed_count++))
    fi
    
    # 요청 간 짧은 대기 (API 부하 방지)
    sleep 0.1
done

echo ""
echo "=== 내보내기 완료 ==="
echo "성공: $exported_count 개"
echo "실패: $failed_count 개"
echo "저장 위치: $OUTPUT_DIR"

# 저장된 파일 목록 표시
echo ""
echo "저장된 파일 목록:"
ls -la "$OUTPUT_DIR"/*.json 2>/dev/null || echo "저장된 파일이 없습니다."