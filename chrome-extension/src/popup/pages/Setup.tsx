import React, { useState } from 'react';

interface Props {
  onComplete: (accounts: string[]) => void;
}

type Step = 'welcome' | 'create' | 'import';

export default function Setup({ onComplete }: Props) {
  const [step, setStep] = useState<Step>('welcome');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [mnemonic, setMnemonic] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCreate = () => {
    if (password.length < 8) {
      setError('Password must be at least 8 characters');
      return;
    }
    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    setLoading(true);
    setError('');

    chrome.runtime.sendMessage(
      { type: 'N42_POPUP_ACTION', action: 'createWallet', payload: { password } },
      (response) => {
        setLoading(false);
        if (response?.success) {
          onComplete(response.accounts);
        } else {
          setError(response?.error || 'Failed to create wallet');
        }
      }
    );
  };

  const handleImport = () => {
    if (!mnemonic.trim()) {
      setError('Please enter your recovery phrase');
      return;
    }
    if (password.length < 8) {
      setError('Password must be at least 8 characters');
      return;
    }

    setLoading(true);
    setError('');

    chrome.runtime.sendMessage(
      {
        type: 'N42_POPUP_ACTION',
        action: 'importWallet',
        payload: { mnemonic: mnemonic.trim(), password },
      },
      (response) => {
        setLoading(false);
        if (response?.success) {
          onComplete(response.accounts);
        } else {
          setError(response?.error || 'Failed to import wallet');
        }
      }
    );
  };

  if (step === 'welcome') {
    return (
      <div style={styles.wrapper}>
        <div style={styles.welcomeIcon}>🌐</div>
        <h1 style={styles.title}>N42 Wallet</h1>
        <p style={styles.subtitle}>Your gateway to Web3</p>

        <div style={styles.buttonGroup}>
          <button onClick={() => setStep('create')} style={styles.primaryBtn}>
            Create New Wallet
          </button>
          <button onClick={() => setStep('import')} style={styles.secondaryBtn}>
            Import Existing Wallet
          </button>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.wrapper}>
      <h2 style={styles.title}>
        {step === 'create' ? 'Create New Wallet' : 'Import Wallet'}
      </h2>

      {step === 'import' && (
        <textarea
          value={mnemonic}
          onChange={(e) => setMnemonic(e.target.value)}
          placeholder="Enter your 12-word recovery phrase..."
          style={styles.textarea}
          rows={3}
        />
      )}

      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password (min 8 characters)"
        style={styles.input}
      />

      {step === 'create' && (
        <input
          type="password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          placeholder="Confirm password"
          style={styles.input}
        />
      )}

      {error && <div style={styles.error}>{error}</div>}

      <button
        onClick={step === 'create' ? handleCreate : handleImport}
        disabled={loading}
        style={styles.primaryBtn}
      >
        {loading ? 'Processing...' : step === 'create' ? 'Create' : 'Import'}
      </button>

      <button onClick={() => setStep('welcome')} style={styles.backBtn}>
        Back
      </button>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  wrapper: {
    padding: 24,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: 16,
  },
  welcomeIcon: { fontSize: 64, marginTop: 40 },
  title: { fontSize: 22, fontWeight: 700, color: '#fafafa' },
  subtitle: { fontSize: 14, color: '#71717a' },
  buttonGroup: {
    display: 'flex',
    flexDirection: 'column',
    gap: 12,
    width: '100%',
    marginTop: 32,
  },
  primaryBtn: {
    width: '100%',
    padding: 14,
    borderRadius: 10,
    border: 'none',
    background: '#3b82f6',
    color: '#fff',
    fontSize: 15,
    fontWeight: 600,
    cursor: 'pointer',
  },
  secondaryBtn: {
    width: '100%',
    padding: 14,
    borderRadius: 10,
    border: '1px solid #3f3f46',
    background: 'none',
    color: '#e4e4e7',
    fontSize: 15,
    fontWeight: 600,
    cursor: 'pointer',
  },
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
  textarea: {
    width: '100%',
    padding: '12px 16px',
    borderRadius: 8,
    border: '1px solid #3f3f46',
    background: '#18181b',
    color: '#fafafa',
    fontSize: 14,
    outline: 'none',
    resize: 'none' as const,
    fontFamily: 'monospace',
  },
  error: { color: '#ef4444', fontSize: 13, textAlign: 'center' },
  backBtn: {
    background: 'none',
    border: 'none',
    color: '#71717a',
    cursor: 'pointer',
    fontSize: 13,
  },
};
