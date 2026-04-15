import React from 'react';

interface Props {
  accounts: string[];
}

export default function Home({ accounts }: Props) {
  const address = accounts[0] || '';
  const shortAddr = address
    ? `${address.slice(0, 6)}...${address.slice(-4)}`
    : 'No account';

  const copyAddress = () => {
    if (address) navigator.clipboard.writeText(address);
  };

  return (
    <div style={styles.wrapper}>
      {/* Account Card */}
      <div style={styles.card}>
        <div style={styles.accountLabel}>Account 1</div>
        <div style={styles.address} onClick={copyAddress} title="Click to copy">
          {shortAddr}
        </div>
        <div style={styles.balance}>0.00 ETH</div>
        <div style={styles.fiatBalance}>$0.00</div>
      </div>

      {/* Action Buttons */}
      <div style={styles.actions}>
        <ActionButton icon="↑" label="Send" />
        <ActionButton icon="↓" label="Receive" />
        <ActionButton icon="⟳" label="Swap" />
        <ActionButton icon="⋯" label="More" />
      </div>

      {/* Activity */}
      <div style={styles.section}>
        <div style={styles.sectionTitle}>Activity</div>
        <div style={styles.empty}>No transactions yet</div>
      </div>

      {/* Network */}
      <div style={styles.network}>
        <div style={styles.networkDot} />
        Ethereum Mainnet
      </div>
    </div>
  );
}

function ActionButton({ icon, label }: { icon: string; label: string }) {
  return (
    <button style={styles.actionBtn}>
      <span style={styles.actionIcon}>{icon}</span>
      <span style={styles.actionLabel}>{label}</span>
    </button>
  );
}

const styles: Record<string, React.CSSProperties> = {
  wrapper: { padding: 16 },
  card: {
    background: 'linear-gradient(135deg, #1e3a5f 0%, #1a1a2e 100%)',
    borderRadius: 16,
    padding: 20,
    textAlign: 'center',
  },
  accountLabel: { fontSize: 12, color: '#94a3b8', marginBottom: 4 },
  address: {
    fontSize: 14,
    color: '#93c5fd',
    cursor: 'pointer',
    marginBottom: 16,
  },
  balance: { fontSize: 28, fontWeight: 700, color: '#fafafa' },
  fiatBalance: { fontSize: 14, color: '#94a3b8', marginTop: 4 },
  actions: {
    display: 'flex',
    justifyContent: 'space-around',
    marginTop: 20,
  },
  actionBtn: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: 6,
    background: 'none',
    border: 'none',
    color: '#e4e4e7',
    cursor: 'pointer',
  },
  actionIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    background: '#27272a',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: 20,
  },
  actionLabel: { fontSize: 12, color: '#a1a1aa' },
  section: { marginTop: 24 },
  sectionTitle: { fontSize: 14, fontWeight: 600, color: '#fafafa', marginBottom: 12 },
  empty: { textAlign: 'center', color: '#52525b', fontSize: 13, padding: 24 },
  network: {
    display: 'flex',
    alignItems: 'center',
    gap: 6,
    fontSize: 12,
    color: '#71717a',
    marginTop: 24,
    justifyContent: 'center',
  },
  networkDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    background: '#22c55e',
  },
};
