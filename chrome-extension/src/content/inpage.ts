/**
 * Injected EIP-1193 Provider for N42 Wallet Chrome Extension.
 *
 * Ported from: lib/features/browser/js/ethereum_provider.dart
 *
 * This script runs in the PAGE context (not content script context).
 * Communication: page ↔ content script via window.postMessage
 *
 * Features:
 * - EIP-1193 compliant Provider
 * - EIP-6963 multi-wallet discovery
 * - MetaMask compatibility shim (isMetaMask: true)
 * - Legacy web3 API support (send/sendAsync/enable)
 */
(function () {
  if ((window as any).ethereum && (window as any).ethereum._isN42) return;

  let _chainId = '0x1';
  let _accounts: string[] = [];
  let _nextId = 1;
  const _cbs: Record<number, { resolve: (v: unknown) => void; reject: (e: unknown) => void }> = {};
  const _evts: Record<string, Array<(...args: unknown[]) => void>> = {};
  let _connected = true;

  function _emit(event: string, data: unknown) {
    const fns = (_evts[event] || []).slice();
    for (const fn of fns) {
      try { fn(data); } catch (e) { console.error('ethereum event error:', e); }
    }
  }

  function ProviderRpcError(code: number, message: string, data?: unknown) {
    const err = new Error(message) as Error & { code: number; data?: unknown };
    err.code = code;
    err.data = data;
    return err;
  }

  // Listen for responses from content script
  window.addEventListener('message', (event) => {
    if (event.source !== window) return;
    const msg = event.data;
    if (!msg || msg.type !== 'N42_RPC_RESPONSE') return;

    const { id, result, error } = msg.payload;
    const cb = _cbs[id];
    if (!cb) return;
    delete _cbs[id];

    if (error) {
      cb.reject(ProviderRpcError(error.code || -32603, error.message || 'Unknown error', error.data));
    } else {
      cb.resolve(result);
    }
  });

  // Listen for events from content script (chainChanged, accountsChanged)
  window.addEventListener('message', (event) => {
    if (event.source !== window) return;
    const msg = event.data;
    if (!msg || msg.type !== 'N42_EVENT') return;

    const { event: evtName, data } = msg.payload;
    if (evtName === 'chainChanged') {
      _chainId = data as string;
      _emit('chainChanged', data);
      _emit('networkChanged', String(parseInt(data as string, 16)));
    } else if (evtName === 'accountsChanged') {
      _accounts = (data as string[]) || [];
      _emit('accountsChanged', _accounts.slice());
    } else {
      _emit(evtName, data);
    }
  });

  const ethereum = {
    _isN42: true,
    isMetaMask: true,
    isConnected: () => _connected,

    _metamask: {
      isUnlocked: () => Promise.resolve(true),
    },

    get chainId() { return _chainId; },
    get networkVersion() { return String(parseInt(_chainId, 16)); },
    get selectedAddress() { return _accounts.length > 0 ? _accounts[0] : null; },

    request(args: { method: string; params?: unknown[] }): Promise<unknown> {
      if (!args || !args.method) {
        return Promise.reject(ProviderRpcError(-32600, 'Invalid request: method is required'));
      }
      const { method, params = [] } = args;

      // Local fast-path methods
      switch (method) {
        case 'eth_chainId':
          return Promise.resolve(_chainId);
        case 'net_version':
          return Promise.resolve(String(parseInt(_chainId, 16)));
        case 'eth_accounts':
          return Promise.resolve(_accounts.slice());
        case 'eth_requestAccounts':
          return Promise.resolve(_accounts.slice());
        case 'eth_coinbase':
          return Promise.resolve(_accounts.length > 0 ? _accounts[0] : null);
        case 'wallet_requestPermissions':
        case 'wallet_getPermissions':
          return Promise.resolve([{
            parentCapability: 'eth_accounts',
            caveats: [{ type: 'restrictReturnedAccounts', value: _accounts.slice() }],
          }]);
        case 'wallet_watchAsset':
          return Promise.resolve(true);
        case 'web3_clientVersion':
          return Promise.resolve('N42Wallet/1.0.0');
        case 'eth_subscribe':
        case 'eth_unsubscribe':
          return Promise.reject(ProviderRpcError(4200, 'Subscriptions are not supported'));
      }

      // Forward to service worker via content script bridge
      const id = _nextId++;
      return new Promise((resolve, reject) => {
        _cbs[id] = { resolve, reject };
        try {
          window.postMessage({
            type: 'N42_RPC_REQUEST',
            payload: { id, method, params },
          }, '*');
        } catch (e) {
          delete _cbs[id];
          reject(ProviderRpcError(-32603, 'Extension bridge unavailable'));
        }
      });
    },

    // Legacy API compatibility
    send(methodOrPayload: string | { method: string; params?: unknown[]; id?: number }, paramsOrCallback?: unknown[] | ((err: unknown, res: unknown) => void)) {
      if (typeof methodOrPayload === 'string') {
        switch (methodOrPayload) {
          case 'eth_accounts':
            return { id: 0, jsonrpc: '2.0', result: _accounts.slice() };
          case 'eth_coinbase':
            return { id: 0, jsonrpc: '2.0', result: _accounts.length > 0 ? _accounts[0] : null };
          case 'net_version':
            return { id: 0, jsonrpc: '2.0', result: String(parseInt(_chainId, 16)) };
          case 'eth_chainId':
            return { id: 0, jsonrpc: '2.0', result: _chainId };
          default:
            return ethereum.request({ method: methodOrPayload, params: (paramsOrCallback as unknown[]) || [] });
        }
      }
      const payload = methodOrPayload;
      if (typeof paramsOrCallback === 'function') {
        ethereum.request({ method: payload.method, params: payload.params || [] })
          .then((r) => (paramsOrCallback as Function)(null, { id: payload.id, jsonrpc: '2.0', result: r }))
          .catch((e) => (paramsOrCallback as Function)(e, null));
        return;
      }
      return ethereum.request({ method: payload.method, params: payload.params || [] });
    },

    sendAsync(payload: { method: string; params?: unknown[]; id?: number }, callback?: (err: unknown, res: unknown) => void) {
      if (!callback || typeof callback !== 'function') {
        return ethereum.request({ method: payload.method, params: payload.params || [] });
      }
      ethereum.request({ method: payload.method, params: payload.params || [] })
        .then((r) => callback(null, { id: payload.id, jsonrpc: '2.0', result: r }))
        .catch((e) => callback(e, null));
    },

    enable() {
      return ethereum.request({ method: 'eth_requestAccounts' });
    },

    // Event system (EIP-1193)
    on(event: string, fn: (...args: unknown[]) => void) {
      if (typeof fn !== 'function') return ethereum;
      if (!_evts[event]) _evts[event] = [];
      _evts[event].push(fn);
      return ethereum;
    },
    addListener(event: string, fn: (...args: unknown[]) => void) { return ethereum.on(event, fn); },

    once(event: string, fn: (...args: unknown[]) => void) {
      if (typeof fn !== 'function') return ethereum;
      const wrapped = (...args: unknown[]) => {
        ethereum.removeListener(event, wrapped);
        fn(...args);
      };
      return ethereum.on(event, wrapped);
    },

    removeListener(event: string, fn: (...args: unknown[]) => void) {
      const fns = _evts[event] || [];
      _evts[event] = fns.filter((f) => f !== fn);
      return ethereum;
    },
    off(event: string, fn: (...args: unknown[]) => void) { return ethereum.removeListener(event, fn); },

    removeAllListeners(event?: string) {
      if (event) { _evts[event] = []; } else { Object.keys(_evts).forEach(k => _evts[k] = []); }
      return ethereum;
    },

    emit(event: string, ...args: unknown[]) {
      const fns = (_evts[event] || []).slice();
      for (const fn of fns) {
        try { fn(...args); } catch (_) { /* noop */ }
      }
      return fns.length > 0;
    },

    listenerCount(event: string) { return (_evts[event] || []).length; },
    listeners(event: string) { return (_evts[event] || []).slice(); },
  };

  // Install
  (window as any).ethereum = ethereum;

  if (!(window as any).web3) {
    (window as any).web3 = { currentProvider: ethereum };
  }

  // EIP-6963: Announce provider for multi-wallet discovery
  try {
    const info = Object.freeze({
      uuid: 'n42-wallet-eip6963',
      name: 'N42 Wallet',
      icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg"/>',
      rdns: 'ai.n42.wallet',
    });
    const detail = Object.freeze({ info, provider: ethereum });
    window.dispatchEvent(new CustomEvent('eip6963:announceProvider', { detail }));
    window.addEventListener('eip6963:requestProvider', () => {
      window.dispatchEvent(new CustomEvent('eip6963:announceProvider', { detail }));
    });
  } catch (_) { /* noop */ }

  window.dispatchEvent(new Event('ethereum#initialized'));

  setTimeout(() => {
    _emit('connect', { chainId: _chainId });
  }, 0);
})();
