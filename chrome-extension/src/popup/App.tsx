import React, { useEffect, useState } from 'react';
import type { ApprovalRequest } from '../shared/types/rpc';
import Unlock from './pages/Unlock';
import Home from './pages/Home';
import SignRequest from './pages/SignRequest';
import Setup from './pages/Setup';

type View = 'loading' | 'setup' | 'unlock' | 'home' | 'approval';

interface WalletState {
  isUnlocked: boolean;
  hasVault: boolean;
  accounts: string[];
  pendingApprovals: ApprovalRequest[];
}

export default function App() {
  const [view, setView] = useState<View>('loading');
  const [state, setState] = useState<WalletState>({
    isUnlocked: false,
    hasVault: false,
    accounts: [],
    pendingApprovals: [],
  });

  useEffect(() => {
    // Get initial state from service worker
    chrome.runtime.sendMessage(
      { type: 'N42_POPUP_ACTION', action: 'getState' },
      (response) => {
        if (!response) {
          setView('setup');
          return;
        }

        setState(response);

        if (response.pendingApprovals?.length > 0) {
          setView('approval');
        } else if (response.isUnlocked) {
          setView('home');
        } else if (response.hasVault || response.accounts?.length > 0) {
          setView('unlock');
        } else {
          setView('setup');
        }
      }
    );
  }, []);

  const handleUnlock = (accounts: string[]) => {
    setState((s) => ({ ...s, isUnlocked: true, hasVault: true, accounts }));
    if (state.pendingApprovals.length > 0) {
      setView('approval');
    } else {
      setView('home');
    }
  };

  const handleSetupComplete = (accounts: string[]) => {
    setState((s) => ({ ...s, isUnlocked: true, hasVault: true, accounts }));
    setView('home');
  };

  const handleApprovalDone = () => {
    setState((s) => ({ ...s, pendingApprovals: s.pendingApprovals.slice(1) }));
    if (state.pendingApprovals.length > 1) {
      setView('approval');
    } else {
      setView('home');
    }
  };

  const handleLock = () => {
    chrome.runtime.sendMessage({ type: 'N42_POPUP_ACTION', action: 'lock' });
    setState((s) => ({ ...s, isUnlocked: false }));
    setView('unlock');
  };

  if (view === 'loading') {
    return (
      <div style={styles.container}>
        <div style={styles.loading}>Loading...</div>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      {/* Header */}
      <div style={styles.header}>
        <div style={styles.logo}>N42 Wallet</div>
        {state.isUnlocked && (
          <button onClick={handleLock} style={styles.lockBtn}>Lock</button>
        )}
      </div>

      {/* Content */}
      <div style={styles.content}>
        {view === 'setup' && <Setup onComplete={handleSetupComplete} />}
        {view === 'unlock' && <Unlock onUnlock={handleUnlock} />}
        {view === 'home' && <Home accounts={state.accounts} />}
        {view === 'approval' && state.pendingApprovals.length > 0 && (
          <SignRequest
            approval={state.pendingApprovals[0]}
            onDone={handleApprovalDone}
          />
        )}
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  container: {
    width: 360,
    height: 600,
    display: 'flex',
    flexDirection: 'column',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
    background: '#0f1118',
    color: '#e4e4e7',
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '12px 16px',
    borderBottom: '1px solid #27272a',
  },
  logo: {
    fontSize: 16,
    fontWeight: 700,
    color: '#3b82f6',
  },
  lockBtn: {
    background: 'none',
    border: '1px solid #3f3f46',
    color: '#a1a1aa',
    borderRadius: 6,
    padding: '4px 12px',
    cursor: 'pointer',
    fontSize: 12,
  },
  content: {
    flex: 1,
    overflow: 'auto',
  },
  loading: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100%',
    color: '#71717a',
  },
};
