import React, { useState, useEffect } from 'react';

const styles = {
  container: {
    minHeight: '100vh',
    backgroundColor: '#f9fafb',
    padding: '24px',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
  },
  loadingContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    minHeight: '50vh',
    fontSize: '18px',
    color: '#6b7280'
  },
  errorContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    minHeight: '50vh',
    fontSize: '18px',
    color: '#dc2626'
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
    alignItems: 'center',
    gap: '16px',
    marginBottom: '24px'
  },
  selectLabel: {
    fontSize: '14px',
    fontWeight: '500',
    color: '#374151'
  },
  select: {
    padding: '8px 12px',
    border: '1px solid #d1d5db',
    borderRadius: '6px',
    outline: 'none',
    fontSize: '14px',
    backgroundColor: 'white',
    cursor: 'pointer'
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

const RDSDashboard = () => {
  const [rawData, setRawData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // 날짜 목록
  const dates = [...new Set(rawData.map(item => item.date))].sort();
  const [selectedDate, setSelectedDate] = useState(dates[0] || '');

  // API Gateway를 통해 RDS 데이터 가져오기
  useEffect(() => {
    const abortController = new AbortController();
    
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await fetch('/api/rds', {
          signal: abortController.signal
        });
        
        if (!response.ok) {
          throw new Error('Failed to fetch RDS data');
        }
        
        const data = await response.json();
        setRawData(data);
        
        // 데이터 로드 후 첫 번째 날짜로 설정
        if (data.length > 0) {
          const uniqueDates = [...new Set(data.map(item => item.date))].sort();
          setSelectedDate(uniqueDates[0]);
        }
      } catch (err) {
        // AbortError는 무시 (정상적인 cleanup)
        if (err.name === 'AbortError') {
          console.log('Fetch aborted');
          return;
        }
        setError(err.message);
        console.error('Error fetching RDS data:', err);
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

  if (loading) {
    return (
      <div style={styles.container}>
        <div style={styles.loadingContainer}>로딩 중...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={styles.container}>
        <div style={styles.errorContainer}>에러: {error}</div>
      </div>
    );
  }

  // 필터링된 데이터
  const filteredData = rawData.filter(item => item.date === selectedDate);

  // 통계 계산
  const totalClusters = [...new Set(filteredData.map(item => item.Cluster))].length;
  const avgWriterCPU = filteredData.length > 0 
    ? (filteredData.reduce((sum, item) => sum + item.WRITER_Max_CPU, 0) / filteredData.length).toFixed(2)
    : '0.00';
  const avgReaderCPU = filteredData.length > 0
    ? (filteredData.reduce((sum, item) => sum + item.READER_Max_CPU, 0) / filteredData.length).toFixed(2)
    : '0.00';
  const totalReaders = filteredData.reduce((sum, item) => sum + item.READER_Count, 0);

  const getCPUColor = (cpu) => {
    if (cpu > 70) return '#dc2626';
    if (cpu > 50) return '#d97706';
    return '#059669';
  };

  return (
    <div style={styles.container}>
      <div style={styles.maxWidth}>
        {/* 헤더 */}
        <div style={styles.header}>
          <h1 style={styles.title}>Aurora RDS 클러스터 모니터링</h1>
          <p style={styles.subtitle}>클러스터별 Writer/Reader CPU 사용량 및 Reader 인스턴스 현황</p>
        </div>

        {/* 날짜 선택 */}
        <div style={styles.card}>
          <div style={styles.controlPanel}>
            <span style={styles.selectLabel}>날짜 선택:</span>
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
            <h3 style={styles.statLabel}>총 클러스터</h3>
            <p style={{...styles.statValue, color: '#111827'}}>{totalClusters}</p>
          </div>
          <div style={styles.statCard}>
            <h3 style={styles.statLabel}>평균 Writer CPU</h3>
            <p style={{...styles.statValue, color: '#2563eb'}}>{avgWriterCPU}%</p>
          </div>
          <div style={styles.statCard}>
            <h3 style={styles.statLabel}>평균 Reader CPU</h3>
            <p style={{...styles.statValue, color: '#059669'}}>{avgReaderCPU}%</p>
          </div>
          <div style={styles.statCard}>
            <h3 style={styles.statLabel}>총 Reader 인스턴스</h3>
            <p style={{...styles.statValue, color: '#d97706'}}>{totalReaders}</p>
          </div>
        </div>

        {/* 상세 테이블 */}
        <div style={styles.card}>
          <div style={{ overflowX: 'auto' }}>
            <table style={styles.table}>
              <thead>
                <tr>
                  <th style={styles.tableHeader}>클러스터</th>
                  <th style={styles.tableHeader}>날짜</th>
                  <th style={styles.tableHeader}>Writer 최대 CPU</th>
                  <th style={styles.tableHeader}>Reader 최대 CPU</th>
                  <th style={styles.tableHeader}>Reader 수</th>
                </tr>
              </thead>
              <tbody>
                {filteredData
                  .sort((a, b) => b.WRITER_Max_CPU - a.WRITER_Max_CPU)
                  .map((item, index) => (
                  <tr key={index} style={index % 2 === 0 ? styles.tableRowEven : styles.tableRowOdd}>
                    <td style={{...styles.tableCell, fontWeight: '500', color: '#111827'}}>
                      {item.Cluster}
                    </td>
                    <td style={{...styles.tableCell, color: '#6b7280'}}>
                      {item.date}
                    </td>
                    <td style={styles.tableCell}>
                      <span style={{fontWeight: '500', color: getCPUColor(item.WRITER_Max_CPU)}}>
                        {item.WRITER_Max_CPU}%
                      </span>
                    </td>
                    <td style={styles.tableCell}>
                      <span style={{fontWeight: '500', color: getCPUColor(item.READER_Max_CPU)}}>
                        {item.READER_Max_CPU}%
                      </span>
                    </td>
                    <td style={styles.tableCell}>
                      <span style={styles.badge}>
                        {item.READER_Count}
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

export default RDSDashboard;