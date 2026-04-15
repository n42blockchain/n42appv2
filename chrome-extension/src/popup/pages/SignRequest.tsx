import React, { useState } from 'react';
import type { ApprovalRequest } from '../../shared/types/rpc';
import { analyzeTxRisk } from '../../shared/security/tx-risk';
import { checkDAppSecurity, type SecurityLevel } from '../../shared/security/dapp-security';

interface Props {
  approval: ApprovalRequest;
  onDone: () => void;
}

export default function SignRequest({ approval, onDone }: Props) {
  const [loading, setLoading] = useState(false);
  const security = checkDAppSecurity(approval.origin);

  const riskAnalysis = approval.type === 'sign_transaction'
    ? analyzeTxRisk((approval.params as any[])?.[0] || {})
    : null;

  const handleApprove = () => {
    setLoading(true);
    chrome.runtime.sendMessage(
      { type: 'N42_POPUP_ACTION', action: 'approve', payload: { id: approval.id } },
      () => {
        setLoading(false);
        onDone();
      }
    );
  };

  const handleReject = () => {
    chrome.runtime.sendMessage(
      { type: 'N42_POPUP_ACTION', action: 'reject', payload: { id: approval.id } },
      () => onDone()
    );
  };

  const securityColors: Record<SecurityLevel, string> = {
    verified: '#22c55e',
    safe: '#3b82f6',
    caution: '#f97316',
    blocked: '#ef4444',
  };

  const riskColors: Record<string, string> = {
    high: '#ef4444',
    medium: '#f97316',
    low: '#22c55e',
    info: '#3b82f6',
  };

  return (
    <div style={styles.wrapper}>
      {/* Origin */}
      <div style={styles.origin}>
        <div style={{
          ...styles.securityBadge,
          background: securityColors[security.level] + '22',
          color: securityColors[security.level],
        }}>
          {security.level.toUpperCase()}
        </div>
        <div style={styles.originUrl}>{new URL(approval.origin).hostname}</div>
      </div>

      {/* Request Type */}
      <div style={styles.requestType}>
        {approval.type === 'sign_message' ? 'Sign Message' : 'Sign Transaction'}
      </div>
      <div style={styles.method}>{approval.method}</div>

      {/* Risk Analysis */}
      {riskAnalysis && (
        <div style={styles.riskSection}>
          <div style={{
            ...styles.riskBadge,
            background: riskColors[riskAnalysis.level] + '22',
            color: riskColors[riskAnalysis.level],
          }}>
            Risk: {riskAnalysis.level.toUpperCase()}
          </div>
          {riskAnalysis.function && (
            <div style={styles.funcName}>Function: {riskAnalysis.function}</div>
          )}
          {riskAnalysis.warnings.map((w, i) => (
            <div key={i} style={styles.warning}>⚠ {w}</div>
          ))}
        </div>
      )}

      {/* Data Preview */}
      <div style={styles.dataSection}>
        <div style={styles.dataLabel}>Data</div>
        <div style={styles.dataContent}>
          {JSON.stringify(approval.params, null, 2).slice(0, 300)}
          {JSON.stringify(approval.params).length > 300 && '...'}
        </div>
      </div>

      {/* Buttons */}
      <div style={styles.buttons}>
        <button onClick={handleReject} style={styles.rejectBtn}>Reject</button>
        <button
          onClick={handleApprove}
          disabled={loading || security.level === 'blocked'}
          style={{
            ...styles.approveBtn,
            opacity: security.level === 'blocked' ? 0.5 : 1,
          }}
        >
          {loading ? 'Signing...' : 'Approve'}
        </button>
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  wrapper: { padding: 16, display: 'flex', flexDirection: 'column', height: '100%' },
  origin: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    padding: '12px 0',
    borderBottom: '1px solid #27272a',
  },
  securityBadge: {
    fontSize: 10,
    fontWeight: 700,
    padding: '2px 8px',
    borderRadius: 4,
  },
  originUrl: { fontSize: 14, color: '#a1a1aa' },
  requestType: { fontSize: 18, fontWeight: 600, color: '#fafafa', marginTop: 16 },
  method: { fontSize: 12, color: '#71717a', fontFamily: 'monospace', marginTop: 4 },
  riskSection: {
    marginTop: 16,
    padding: 12,
    borderRadius: 8,
    background: '#18181b',
    display: 'flex',
    flexDirection: 'column',
    gap: 8,
  },
  riskBadge: {
    fontSize: 11,
    fontWeight: 700,
    padding: '2px 8px',
    borderRadius: 4,
    alignSelf: 'flex-start',
  },
  funcName: { fontSize: 13, color: '#a1a1aa', fontFamily: 'monospace' },
  warning: { fontSize: 12, color: '#f97316' },
  dataSection: {
    marginTop: 16,
    flex: 1,
    overflow: 'auto',
  },
  dataLabel: { fontSize: 12, color: '#71717a', marginBottom: 8 },
  dataContent: {
    fontSize: 11,
    color: '#a1a1aa',
    fontFamily: 'monospace',
    background: '#18181b',
    borderRadius: 8,
    padding: 12,
    whiteSpace: 'pre-wrap',
    wordBreak: 'break-all',
    maxHeight: 200,
    overflow: 'auto',
  },
  buttons: {
    display: 'flex',
    gap: 12,
    marginTop: 16,
    paddingTop: 16,
    borderTop: '1px solid #27272a',
  },
  rejectBtn: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    border: '1px solid #3f3f46',
    background: 'none',
    color: '#e4e4e7',
    fontSize: 15,
    fontWeight: 600,
    cursor: 'pointer',
  },
  approveBtn: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    border: 'none',
    background: '#3b82f6',
    color: '#fff',
    fontSize: 15,
    fontWeight: 600,
    cursor: 'pointer',
  },
};
