/**
 * Content Script Bridge — connects page (inpage.ts) to service worker.
 *
 * Communication flow:
 *   Page → window.postMessage → bridge → chrome.runtime.sendMessage → Service Worker
 *   Service Worker → chrome.runtime.onMessage → bridge → window.postMessage → Page
 *
 * This script runs in the CONTENT SCRIPT context (isolated world).
 */

// Inject inpage.ts into the page context
const script = document.createElement('script');
script.src = chrome.runtime.getURL('content-inpage.js');
script.type = 'module';
(document.head || document.documentElement).appendChild(script);
script.onload = () => script.remove();

// Page → Service Worker: Forward RPC requests
window.addEventListener('message', (event) => {
  if (event.source !== window) return;
  const msg = event.data;
  if (!msg || msg.type !== 'N42_RPC_REQUEST') return;

  chrome.runtime.sendMessage(
    {
      type: 'N42_RPC_REQUEST',
      payload: msg.payload,
      origin: window.location.origin,
    },
    (response) => {
      if (chrome.runtime.lastError) {
        // Service worker not available
        window.postMessage({
          type: 'N42_RPC_RESPONSE',
          payload: {
            id: msg.payload.id,
            error: { code: -32603, message: 'Extension unavailable' },
          },
        }, '*');
        return;
      }
      if (response) {
        window.postMessage({
          type: 'N42_RPC_RESPONSE',
          payload: response,
        }, '*');
      }
    }
  );
});

// Service Worker → Page: Forward events (chainChanged, accountsChanged)
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'N42_EVENT') {
    window.postMessage({
      type: 'N42_EVENT',
      payload: message.payload,
    }, '*');
  }
});

console.log('[N42 Wallet] Content script loaded');
