import React, { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const K8sDashboard = () => {
  const [selectedView, setSelectedView] = useState('cpu');
  const [rawData, setRawData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // 날짜 목록
  const dates = [...new Set(rawData.map(item => item.date))];
  const [selectedDate, setSelectedDate] = useState(dates[0] || '2025-09-16');

  // API Gateway를 통해 데이터 가져오기
  useEffect(() => {
    const abortController = new AbortController();
    
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await fetch('/api/event', {
          signal: abortController.signal
        });
        
        if (!response.ok) {
          throw new Error('Failed to fetch data');
        }
        
        const data = await response.json();
        setRawData(data);
        
        // 데이터 로드 후 첫 번째 날짜로 설정
        if (data.length > 0) {
          const uniqueDates = [...new Set(data.map(item => item.date))];
          setSelectedDate(uniqueDates[0]);
        }
      } catch (err) {
        // AbortError는 무시 (정상적인 cleanup)
        if (err.name === 'AbortError') {
          console.log('Fetch aborted');
          return;
        }
        setError(err.message);
        console.error('Error fetching data:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();

    // Cleanup: 컴포넌트 언마운트 시 fetch 취소
    return () => {
      abortController.abort();
    };
  }, []);

  // 로딩 상태 처리
  if (loading) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        fontSize: '18px',
        color: '#6b7280'
      }}>
        로딩 중...
      </div>
    );
  }

  // 에러 상태 처리
  if (error) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        fontSize: '18px',
        color: '#dc2626'
      }}>
        에러: {error}
      </div>
    );
  }

  // CPU 사용량 기준 차트 데이터 (선택된 날짜만)
  const cpuChartData = rawData
    .filter(item => item.date === selectedDate)
    .map(item => ({
      namespace: item.namespace,
      cpu: item.avg_max_cpu
    }))
    .sort((a, b) => b.cpu - a.cpu);

  // Pod 수 기준 차트 데이터 (선택된 날짜만)
  const podChartData = rawData
    .filter(item => item.date === selectedDate)
    .map(item => ({
      namespace: item.namespace,
      pods: item.pod_count
    }))
    .sort((a, b) => b.pods - a.pods);

  // 필터링된 데이터
  const filteredData = rawData.filter(item => item.date === selectedDate);

  // 통계 계산
  const namespaces = [...new Set(filteredData.map(item => item.namespace))];
  const totalPods = filteredData.reduce((sum, item) => sum + item.pod_count, 0);
  const avgCPU = filteredData.length > 0 
    ? (filteredData.reduce((sum, item) => sum + item.avg_max_cpu, 0) / filteredData.length).toFixed(2)
    : '0.00';

  const getCPUColor = (cpu) => {
    if (cpu > 40) return '#dc2626';
    if (cpu > 20) return '#d97706';
    return '#059669';
  };

  // 스타일 정의
  const styles = {
    container: {
      minHeight: '100vh',
      backgroundColor: '#f9fafb',
      padding: '24px',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    },
    maxWidth: {
      maxWidth: '1400px',
      margin: '0 auto'
    },
    card: {
      backgroundColor: 'white',
      borderRadius: '8px',
      boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
      padding: '24px',
      marginBottom: '24px'
    },
    header: {
      marginBottom: '32px'
    },
    title: {
      fontSize: '30px',
      fontWeight: 'bold',
      color: '#111827',
      marginBottom: '8px'
    },
    subtitle: {
      color: '#6b7280'
    },
    controlPanel: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: '16px',
      alignItems: 'center'
    },
    buttonGroup: {
      display: 'flex',
      gap: '8px'
    },
    button: {
      padding: '8px 16px',
      borderRadius: '6px',
      border: 'none',
      fontWeight: '500',
      cursor: 'pointer',
      transition: 'all 0.2s'
    },
    buttonActive: {
      backgroundColor: '#2563eb',
      color: 'white'
    },
    buttonInactive: {
      backgroundColor: '#e5e7eb',
      color: '#374151'
    },
    select: {
      padding: '8px 12px',
      border: '1px solid #d1d5db',
      borderRadius: '6px',
      outline: 'none',
      fontSize: '14px'
    },
    statsGrid: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
      gap: '24px',
      marginBottom: '24px'
    },
    statCard: {
      backgroundColor: 'white',
      borderRadius: '8px',
      boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
      padding: '24px'
    },
    statLabel: {
      fontSize: '14px',
      fontWeight: '500',
      color: '#6b7280',
      marginBottom: '8px'
    },
    statValue: {
      fontSize: '24px',
      fontWeight: 'bold'
    },
    chartContainer: {
      width: '100%',
      height: '400px'
    },
    sectionTitle: {
      fontSize: '20px',
      fontWeight: '600',
      color: '#111827',
      marginBottom: '16px'
    },
    table: {
      width: '100%',
      borderCollapse: 'collapse'
    },
    tableHeader: {
      backgroundColor: '#f9fafb',
      padding: '12px 24px',
      textAlign: 'left',
      fontSize: '12px',
      fontWeight: '500',
      color: '#6b7280',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      borderBottom: '1px solid #e5e7eb'
    },
    tableCell: {
      padding: '16px 24px',
      fontSize: '14px',
      borderBottom: '1px solid #e5e7eb'
    },
    tableRowEven: {
      backgroundColor: 'white'
    },
    tableRowOdd: {
      backgroundColor: '#f9fafb'
    },
    badge: {
      display: 'inline-flex',
      alignItems: 'center',
      padding: '2px 10px',
      borderRadius: '9999px',
      fontSize: '12px',
      fontWeight: '500',
      backgroundColor: '#dbeafe',
      color: '#1e40af'
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.maxWidth}>
        {/* 헤더 */}
        <div style={styles.header}>
          <h1 style={styles.title}>Kubernetes 클러스터 모니터링</h1>
          <p style={styles.subtitle}>네임스페이스별 리소스 사용량 및 Pod 현황</p>
        </div>

        {/* 컨트롤 패널 */}
        <div style={styles.card}>
          <div style={styles.controlPanel}>
            <div style={styles.buttonGroup}>
              <button
                onClick={() => setSelectedView('cpu')}
                style={{
                  ...styles.button,
                  ...(selectedView === 'cpu' ? styles.buttonActive : styles.buttonInactive)
                }}
              >
                CPU 사용량
              </button>
              <button
                onClick={() => setSelectedView('pods')}
                style={{
                  ...styles.button,
                  ...(selectedView === 'pods' ? styles.buttonActive : styles.buttonInactive)
                }}
              >
                Pod 수
              </button>
            </div>
            
            <select
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              style={styles.select}
            >
              {dates.map(date => (
                <option key={date} value={date}>{date}</option>
              ))}
            </select>
          </div>
        </div>

        {/* 요약 통계 */}
        <div style={styles.statsGrid}>
          <div style={styles.statCard}>
            <h3 style={styles.statLabel}>총 네임스페이스</h3>
            <p style={{...styles.statValue, color: '#111827'}}>{namespaces.length}</p>
          </div>
          <div style={styles.statCard}>
            <h3 style={styles.statLabel}>총 Pod 수</h3>
            <p style={{...styles.statValue, color: '#2563eb'}}>{totalPods}</p>
          </div>
          <div style={styles.statCard}>
            <h3 style={styles.statLabel}>평균 CPU 사용량</h3>
            <p style={{...styles.statValue, color: '#059669'}}>{avgCPU}%</p>
          </div>
        </div>

        {/* 메인 차트 영역 */}
        <div style={styles.card}>
          <h2 style={styles.sectionTitle}>
            {selectedView === 'cpu' && 'CPU 사용량 비교'}
            {selectedView === 'pods' && 'Pod 수 비교'}
          </h2>
          
          <div style={styles.chartContainer}>
            {selectedView === 'cpu' && (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={cpuChartData} margin={{ top: 5, right: 30, left: 20, bottom: 80 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis 
                    dataKey="namespace" 
                    angle={-45} 
                    textAnchor="end" 
                    height={80}
                    fontSize={12}
                  />
                  <YAxis label={{ value: 'CPU 사용량 (%)', angle: -90, position: 'insideLeft' }} />
                  <Tooltip formatter={(value) => [`${value}%`, 'CPU 사용량']} />
                  <Bar dataKey="cpu" fill="#3B82F6" />
                </BarChart>
              </ResponsiveContainer>
            )}
            
            {selectedView === 'pods' && (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={podChartData} margin={{ top: 5, right: 30, left: 20, bottom: 80 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis 
                    dataKey="namespace" 
                    angle={-45} 
                    textAnchor="end" 
                    height={80}
                    fontSize={12}
                  />
                  <YAxis label={{ value: 'Pod 수', angle: -90, position: 'insideLeft' }} />
                  <Tooltip formatter={(value) => [value, 'Pod 수']} />
                  <Bar dataKey="pods" fill="#10B981" />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>

        {/* 상세 테이블 */}
        <div style={styles.card}>
          <h2 style={styles.sectionTitle}>상세 정보</h2>
          <div style={{ overflowX: 'auto' }}>
            <table style={styles.table}>
              <thead>
                <tr>
                  <th style={styles.tableHeader}>네임스페이스</th>
                  <th style={styles.tableHeader}>날짜</th>
                  <th style={styles.tableHeader}>Pod 수</th>
                  <th style={styles.tableHeader}>평균 최대 CPU 사용량</th>
                </tr>
              </thead>
              <tbody>
                {filteredData
                  .sort((a, b) => b.avg_max_cpu - a.avg_max_cpu)
                  .map((item, index) => (
                  <tr key={index} style={index % 2 === 0 ? styles.tableRowEven : styles.tableRowOdd}>
                    <td style={{...styles.tableCell, fontWeight: '500', color: '#111827'}}>
                      {item.namespace}
                    </td>
                    <td style={{...styles.tableCell, color: '#6b7280'}}>
                      {item.date}
                    </td>
                    <td style={styles.tableCell}>
                      <span style={styles.badge}>
                        {item.pod_count}
                      </span>
                    </td>
                    <td style={styles.tableCell}>
                      <span style={{fontWeight: '500', color: getCPUColor(item.avg_max_cpu)}}>
                        {item.avg_max_cpu}%
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default K8sDashboard;