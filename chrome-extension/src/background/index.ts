/**
 * Service Worker entry point for N42 Wallet Chrome Extension.
 *
 * Responsibilities:
 * - Listen for messages from content scripts
 * - Route RPC requests via rpc-router
 * - Manage keyring lifecycle
 * - Initialize phishing detection
 */

import { initPhishingDetector } from '../shared/security/phishing';
import { handleRequest, getPendingApprovals, approveRequest, rejectRequest } from './rpc-router';
import * as keyring from './keyring';

// ── Initialize ──
initPhishingDetector().catch(console.error);

// ── Message handler ──
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'N42_RPC_REQUEST') {
    // DApp RPC request from content script
    const origin = message.origin || sender.url || '';
    handleRequest(message.payload, origin)
      .then((response) => {
        sendResponse({
          id: message.payload.id,
          ...response,
        });
      })
      .catch((err) => {
        sendResponse({
          id: message.payload.id,
          error: { code: -32603, message: String(err) },
        });
      });
    return true; // async sendResponse
  }

  if (message.type === 'N42_POPUP_ACTION') {
    // Actions from popup UI
    const { action, payload } = message;
    switch (action) {
      case 'getState':
        sendResponse({
          isUnlocked: keyring.isUnlocked(),
          accounts: keyring.getAccounts(),
          pendingApprovals: getPendingApprovals(),
        });
        break;

      case 'unlock':
        keyring.unlock(payload.password).then((success) => {
          sendResponse({ success, accounts: keyring.getAccounts() });
        });
        return true;

      case 'lock':
        keyring.lock();
        sendResponse({ success: true });
        break;

      case 'createWallet':
        keyring.createWallet(payload.password).then((accounts) => {
          sendResponse({ success: true, accounts });
        }).catch((err) => {
          sendResponse({ success: false, error: String(err) });
        });
        return true;

      case 'importWallet':
        keyring.importWallet(payload.mnemonic, payload.password).then((accounts) => {
          sendResponse({ success: true, accounts });
        }).catch((err) => {
          sendResponse({ success: false, error: String(err) });
        });
        return true;

      case 'approve':
        approveRequest(payload.id).then(() => {
          sendResponse({ success: true });
        });
        return true;

      case 'reject':
        rejectRequest(payload.id);
        sendResponse({ success: true });
        break;

      default:
        sendResponse({ error: 'Unknown action' });
    }
  }

  return false;
});

// ── Auto-refresh phishing list every 6 hours ──
chrome.alarms.create('refreshPhishing', { periodInMinutes: 360 });
chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'refreshPhishing') {
    initPhishingDetector().catch(console.error);
  }
});

console.log('[N42 Wallet] Service worker initialized');
