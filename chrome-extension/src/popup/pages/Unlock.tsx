import React, { useState } from 'react';

interface Props {
  onUnlock: (accounts: string[]) => void;
}

export default function Unlock({ onUnlock }: Props) {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!password) return;

    setLoading(true);
    setError('');

    chrome.runtime.sendMessage(
      { type: 'N42_POPUP_ACTION', action: 'unlock', payload: { password } },
      (response) => {
        setLoading(false);
        if (response?.success) {
          onUnlock(response.accounts || []);
        } else {
          setError('Incorrect password');
        }
      }
    );
  };

  return (
    <div style={styles.wrapper}>
      <div style={styles.icon}>🔒</div>
      <h2 style={styles.title}>Welcome Back</h2>
      <p style={styles.subtitle}>Enter your password to unlock</p>

      <form onSubmit={handleSubmit} style={styles.form}>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          style={styles.input}
          autoFocus
        />
        {error && <div style={styles.error}>{error}</div>}
        <button type="submit" disabled={loading || !password} style={styles.button}>
          {loading ? 'Unlocking...' : 'Unlock'}
        </button>
      </form>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  wrapper: { padding: 24, textAlign: 'center' },
  icon: { fontSize: 48, marginTop: 40 },
  title: { fontSize: 20, fontWeight: 600, marginTop: 16, color: '#fafafa' },
  subtitle: { fontSize: 14, color: '#71717a', marginTop: 8 },
  form: { marginTop: 32, display: 'flex', flexDirection: 'column', gap: 12 },
  input: {
    width: '100%',
    padding: '12px 16px',
    borderRadius: 8,
    border: '1px solid #3f3f46',
    background: '#18181b',
    color: '#fafafa',
    fontSize: 14,
    outline: 'none',
  },
  error: { color: '#ef4444', fontSize: 13 },
  button: {
    width: '100%',
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
