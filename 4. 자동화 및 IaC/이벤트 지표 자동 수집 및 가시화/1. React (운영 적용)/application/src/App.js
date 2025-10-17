// src/App.jsx
import React, { useState } from 'react';
import K8sDashboard from './components/K8sDashboard';
import RDSDashboard from './components/RDSDashboard';

function App() {
  const [activeTab, setActiveTab] = useState('k8s');

  const styles = {
    container: {
      minHeight: '100vh',
      backgroundColor: '#f9fafb'
    },
    tabContainer: {
      backgroundColor: 'white',
      borderBottom: '1px solid #e5e7eb',
      position: 'sticky',
      top: 0,
      zIndex: 10,
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
    },
    tabInner: {
      maxWidth: '1400px',
      margin: '0 auto',
      display: 'flex',
      gap: '8px',
      padding: '16px 24px'
    },
    tab: {
      padding: '12px 24px',
      border: 'none',
      backgroundColor: 'transparent',
      cursor: 'pointer',
      fontSize: '16px',
      fontWeight: '500',
      borderRadius: '6px',
      transition: 'all 0.2s'
    },
    tabActive: {
      backgroundColor: '#2563eb',
      color: 'white'
    },
    tabInactive: {
      color: '#6b7280',
      backgroundColor: 'transparent'
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.tabContainer}>
        <div style={styles.tabInner}>
          <button
            onClick={() => setActiveTab('k8s')}
            style={{
              ...styles.tab,
              ...(activeTab === 'k8s' ? styles.tabActive : styles.tabInactive)
            }}
          >
            🎯 Kubernetes
          </button>
          <button
            onClick={() => setActiveTab('rds')}
            style={{
              ...styles.tab,
              ...(activeTab === 'rds' ? styles.tabActive : styles.tabInactive)
            }}
          >
            💾 Aurora RDS
          </button>
        </div>
      </div>
      
      {activeTab === 'k8s' && <K8sDashboard />}
      {activeTab === 'rds' && <RDSDashboard />}
    </div>
  );
}

export default App;