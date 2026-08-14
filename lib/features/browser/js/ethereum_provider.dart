/// Builds the JavaScript IIFE that defines `window.ethereum` (EIP-1193).
///
/// **Status: live (wired 2026-07+).** `BrowserProvider` registers the
/// `N42Wallet` JavaScriptChannel, injects this script on page start/finish,
/// and routes messages into `DAppRequestHandler`. [accounts] is only seeded
/// for origins the user has connected — other pages get an empty list and
/// must go through `eth_requestAccounts` (native connect approval).
///
/// Injection strategy:
///   1. iOS WKWebView: injected as WKUserScript at document-start time
///   2. Android WebView: `runJavaScript` at both onPageStarted + onPageFinished
///   3. The IIFE is idempotent — safe to run multiple times
///
/// Communication flow:
///   JS  -> `N42Wallet.postMessage(json)` -> Dart `JavaScriptChannel`
///   Dart -> `runJavaScript('window.ethereum._n42Cb(...)')` -> JS
class EthereumProviderJs {
  EthereumProviderJs._();

  /// Returns a self-contained JavaScript string that creates `window.ethereum`.
  ///
  /// [chainIdHex]  e.g. "0x1" for mainnet
  /// [accounts]    e.g. ["0xabc..."]  — current wallet address(es)
  static String buildProviderScript(String chainIdHex, List<String> accounts) {
    final accountsJson = accounts.map((a) => '"$a"').join(',');

    return '''
(function() {
  if (window.ethereum && window.ethereum._isN42) return;

  var _chainId = "$chainIdHex";
  var _accounts = [$accountsJson];
  var _nextId = 1;
  var _cbs = {};
  var _evts = {};
  var _connected = true;

  function _emit(event, data) {
    var fns = (_evts[event] || []).slice();
    for (var i = 0; i < fns.length; i++) {
      try { fns[i](data); } catch(e) { console.error("ethereum event error:", e); }
    }
  }

  // EIP-1193 ProviderRpcError
  function ProviderRpcError(code, message, data) {
    var err = new Error(message);
    err.code = code;
    err.data = data;
    return err;
  }

  // 解析原生桥。Android 上 window.N42Wallet 是 addJavascriptInterface 注入的
  // 真实对象，始终可用；iOS(WKWebView) 上它只是一段 atDocumentStart 的
  // WKUserScript 起的别名（window.N42Wallet = webkit.messageHandlers.N42Wallet），
  // 若该 user script 在页面开始加载时尚未注册完成，别名就会缺失，整条 DApp
  // 通道表现为 "-32603 Native bridge unavailable"。消息处理器本身此时已经
  // 可用，因此直接回退到 webkit.messageHandlers 兜底。
  function _bridge() {
    try {
      if (typeof N42Wallet !== "undefined" && N42Wallet && N42Wallet.postMessage) {
        return N42Wallet;
      }
    } catch(e) {}
    try {
      if (window.webkit && window.webkit.messageHandlers &&
          window.webkit.messageHandlers.N42Wallet) {
        return window.webkit.messageHandlers.N42Wallet;
      }
    } catch(e) {}
    return null;
  }

  // NOTE: isMetaMask is intentionally true for DApp compatibility.
  // Many legacy DApps only check `window.ethereum.isMetaMask` to detect
  // an injected wallet. Setting false causes "Install MetaMask" prompts.
  // Our true identity is exposed via EIP-6963 with rdns "ai.n42.wallet".
  var ethereum = {
    _isN42: true,
    isMetaMask: true,
    isConnected: function() { return _connected; },

    // MetaMask-specific namespace — some DApps check this
    _metamask: {
      isUnlocked: function() { return Promise.resolve(true); }
    },

    // Readable properties
    get chainId() { return _chainId; },
    get networkVersion() { return String(parseInt(_chainId, 16)); },
    get selectedAddress() { return _accounts.length > 0 ? _accounts[0] : null; },

    request: function(args) {
      if (!args || !args.method) {
        return Promise.reject(ProviderRpcError(
          -32600, "Invalid request: method is required"));
      }
      var method = args.method;
      var params = args.params || [];

      // ── Local fast-path methods ──────────────────────────────────────
      switch(method) {
        case "eth_chainId":
          return Promise.resolve(_chainId);
        case "net_version":
          return Promise.resolve(String(parseInt(_chainId, 16)));
        case "eth_accounts":
          return Promise.resolve(_accounts.slice());
        case "eth_requestAccounts":
          // Only fast-path once connected; first call must reach native so
          // the user sees the connect approval sheet.
          if (_accounts.length > 0) return Promise.resolve(_accounts.slice());
          break;
        case "eth_coinbase":
          return Promise.resolve(_accounts.length > 0 ? _accounts[0] : null);
        case "wallet_requestPermissions":
          // Not yet connected: route through eth_requestAccounts so the
          // native connect approval runs, then report the granted permission.
          if (_accounts.length === 0) {
            return ethereum.request({ method: "eth_requestAccounts" })
              .then(function(accs) {
                return [{
                  parentCapability: "eth_accounts",
                  caveats: [{type: "restrictReturnedAccounts", value: accs}]
                }];
              });
          }
          return Promise.resolve([{
            parentCapability: "eth_accounts",
            caveats: [{type: "restrictReturnedAccounts", value: _accounts.slice()}]
          }]);
        case "wallet_getPermissions":
          if (_accounts.length === 0) return Promise.resolve([]);
          return Promise.resolve([{
            parentCapability: "eth_accounts",
            caveats: [{type: "restrictReturnedAccounts", value: _accounts.slice()}]
          }]);
        case "wallet_watchAsset":
          // Accept but do nothing — return true as success per EIP-747
          return Promise.resolve(true);
        case "web3_clientVersion":
          return Promise.resolve("N42Wallet/1.0.0");
        case "web3_sha3":
          // This can be forwarded to RPC
          break;
        case "eth_subscribe":
        case "eth_unsubscribe":
          // Subscriptions not supported in injected provider
          return Promise.reject(ProviderRpcError(
            4200, "Subscriptions are not supported"));
      }

      // ── Forward to native ────────────────────────────────────────────
      var id = _nextId++;
      return new Promise(function(resolve, reject) {
        _cbs[id] = { resolve: resolve, reject: reject };
        var bridge = _bridge();
        if (!bridge) {
          delete _cbs[id];
          reject(ProviderRpcError(-32603, "Native bridge unavailable"));
          return;
        }
        try {
          bridge.postMessage(JSON.stringify({
            id: id,
            method: method,
            params: params
          }));
        } catch(e) {
          delete _cbs[id];
          reject(ProviderRpcError(-32603, "Native bridge unavailable"));
        }
      });
    },

    // ── Legacy API compatibility ─────────────────────────────────────
    // MetaMask deprecated these but many DApps still use them
    send: function(methodOrPayload, paramsOrCallback) {
      // send("eth_chainId") → synchronous-like for known local methods
      if (typeof methodOrPayload === "string") {
        var m = methodOrPayload;
        // Synchronous return for known local values (legacy pattern)
        switch(m) {
          case "eth_accounts":
            return { id: 0, jsonrpc: "2.0", result: _accounts.slice() };
          case "eth_coinbase":
            return { id: 0, jsonrpc: "2.0", result: _accounts.length > 0 ? _accounts[0] : null };
          case "net_version":
            return { id: 0, jsonrpc: "2.0", result: String(parseInt(_chainId, 16)) };
          case "eth_chainId":
            return { id: 0, jsonrpc: "2.0", result: _chainId };
          default:
            // Otherwise, return a promise
            return ethereum.request({ method: m, params: paramsOrCallback || [] });
        }
      }
      // JSON-RPC payload object
      var payload = methodOrPayload;
      if (typeof paramsOrCallback === "function") {
        ethereum.request({ method: payload.method, params: payload.params || [] })
          .then(function(r) { paramsOrCallback(null, { id: payload.id, jsonrpc: "2.0", result: r }); })
          .catch(function(e) { paramsOrCallback(e, null); });
        return;
      }
      return ethereum.request({ method: payload.method, params: payload.params || [] });
    },

    sendAsync: function(payload, callback) {
      if (!callback || typeof callback !== "function") {
        return ethereum.request({ method: payload.method, params: payload.params || [] });
      }
      ethereum.request({ method: payload.method, params: payload.params || [] })
        .then(function(r) { callback(null, { id: payload.id, jsonrpc: "2.0", result: r }); })
        .catch(function(e) { callback(e, null); });
    },

    enable: function() {
      return ethereum.request({ method: "eth_requestAccounts" });
    },

    // ── Event system (EIP-1193) ──────────────────────────────────────
    on: function(event, fn) {
      if (typeof fn !== "function") return ethereum;
      if (!_evts[event]) _evts[event] = [];
      _evts[event].push(fn);
      return ethereum;
    },
    addListener: function(event, fn) { return ethereum.on(event, fn); },

    once: function(event, fn) {
      if (typeof fn !== "function") return ethereum;
      var wrapped = function() {
        ethereum.removeListener(event, wrapped);
        fn.apply(this, arguments);
      };
      return ethereum.on(event, wrapped);
    },

    removeListener: function(event, fn) {
      var fns = _evts[event] || [];
      _evts[event] = fns.filter(function(f) { return f !== fn; });
      return ethereum;
    },
    off: function(event, fn) { return ethereum.removeListener(event, fn); },

    removeAllListeners: function(event) {
      if (event) { _evts[event] = []; } else { _evts = {}; }
      return ethereum;
    },

    emit: function(event) {
      var args = Array.prototype.slice.call(arguments, 1);
      var fns = (_evts[event] || []).slice();
      for (var i = 0; i < fns.length; i++) {
        try { fns[i].apply(null, args); } catch(e) {}
      }
      return fns.length > 0;
    },

    listenerCount: function(event) {
      return (_evts[event] || []).length;
    },

    listeners: function(event) {
      return (_evts[event] || []).slice();
    },

    // 诊断用：返回当前使用的原生桥类型 —— "direct"(window.N42Wallet)、
    // "webkit"(回退到 webkit.messageHandlers)、"none"(桥不可用)。
    // 真机排障时可在 Safari/Chrome inspector 里直接调用。
    _n42BridgeStatus: function() {
      try {
        if (typeof N42Wallet !== "undefined" && N42Wallet && N42Wallet.postMessage) {
          return "direct";
        }
      } catch(e) {}
      try {
        if (window.webkit && window.webkit.messageHandlers &&
            window.webkit.messageHandlers.N42Wallet) {
          return "webkit";
        }
      } catch(e) {}
      return "none";
    },

    // ── Native callback: resolve a pending request ───────────────────
    _n42Cb: function(id, resultJson, errorJson) {
      var cb = _cbs[id];
      if (!cb) return;
      delete _cbs[id];
      if (errorJson !== null && errorJson !== undefined) {
        var errObj;
        try { errObj = JSON.parse(errorJson); } catch(e) { errObj = { message: errorJson }; }
        cb.reject(ProviderRpcError(
          errObj.code || -32603,
          errObj.message || "Unknown error",
          errObj.data
        ));
      } else {
        var result;
        try { result = JSON.parse(resultJson); } catch(e) { result = resultJson; }
        cb.resolve(result);
      }
    },

    // ── Native callback: chain switched ──────────────────────────────
    _n42SetChain: function(hex) {
      if (_chainId === hex) return;
      _chainId = hex;
      _emit("chainChanged", hex);
      // Deprecated but some DApps listen to this
      _emit("networkChanged", String(parseInt(hex, 16)));
    },

    // ── Native callback: accounts changed ────────────────────────────
    _n42SetAccounts: function(accs) {
      _accounts = accs || [];
      _emit("accountsChanged", _accounts.slice());
    }
  };

  // ── Install ────────────────────────────────────────────────────────
  // Override any existing provider (e.g. from previous navigation)
  window.ethereum = ethereum;

  // Legacy web3 shim — some old DApps check `window.web3.currentProvider`
  if (!window.web3) {
    window.web3 = { currentProvider: ethereum };
  }

  // EIP-6963: Announce provider for multi-wallet discovery
  try {
    var info = {
      uuid: "n42-wallet-eip6963",
      name: "N42 Wallet",
      icon: "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg'/>",
      rdns: "ai.n42.wallet"
    };
    var detail = Object.freeze({ info: Object.freeze(info), provider: ethereum });
    window.dispatchEvent(new CustomEvent("eip6963:announceProvider", { detail: detail }));
    // Re-announce on request
    window.addEventListener("eip6963:requestProvider", function() {
      window.dispatchEvent(new CustomEvent("eip6963:announceProvider", { detail: detail }));
    });
  } catch(e) {}

  // Standard initialization events
  window.dispatchEvent(new Event("ethereum#initialized"));

  // Emit connect event (EIP-1193 §4.1)
  setTimeout(function() {
    _emit("connect", { chainId: _chainId });
  }, 0);
})();
''';
  }
}
