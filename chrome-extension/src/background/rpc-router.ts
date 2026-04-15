/**
 * RPC Router — handles DApp JSON-RPC requests.
 *
 * Ported from: lib/features/browser/handler/dapp_request_handler.dart
 *
 * Routes requests to:
 * - Local handlers (accounts, chain info)
 * - Keyring (signing operations)
 * - Remote RPC (eth_call, eth_getBalance, etc.)
 * - Popup approval (sign, sendTransaction)
 */

import type { RpcRequest, ApprovalRequest, NetworkConfig } from '../shared/types/rpc';
import { isPhishing } from '../shared/security/phishing';
import { checkDAppSecurity } from '../shared/security/dapp-security';
import { analyzeTxRisk } from '../shared/security/tx-risk';
import * as keyring from './keyring';

/** Default networks */
export const NETWORKS: Record<number, NetworkConfig> = {
  1: { chainId: 1, chainIdHex: '0x1', name: 'Ethereum', rpcUrl: 'https://eth.llamarpc.com', symbol: 'ETH', decimals: 18, explorerUrl: 'https://etherscan.io' },
  56: { chainId: 56, chainIdHex: '0x38', name: 'BNB Chain', rpcUrl: 'https://bsc-dataseed.binance.org', symbol: 'BNB', decimals: 18, explorerUrl: 'https://bscscan.com' },
  137: { chainId: 137, chainIdHex: '0x89', name: 'Polygon', rpcUrl: 'https://polygon-rpc.com', symbol: 'MATIC', decimals: 18, explorerUrl: 'https://polygonscan.com' },
  42161: { chainId: 42161, chainIdHex: '0xa4b1', name: 'Arbitrum', rpcUrl: 'https://arb1.arbitrum.io/rpc', symbol: 'ETH', decimals: 18, explorerUrl: 'https://arbiscan.io' },
  10: { chainId: 10, chainIdHex: '0xa', name: 'Optimism', rpcUrl: 'https://mainnet.optimism.io', symbol: 'ETH', decimals: 18, explorerUrl: 'https://optimistic.etherscan.io' },
  8453: { chainId: 8453, chainIdHex: '0x2105', name: 'Base', rpcUrl: 'https://mainnet.base.org', symbol: 'ETH', decimals: 18, explorerUrl: 'https://basescan.org' },
  43114: { chainId: 43114, chainIdHex: '0xa86a', name: 'Avalanche', rpcUrl: 'https://api.avax.network/ext/bc/C/rpc', symbol: 'AVAX', decimals: 18, explorerUrl: 'https://snowtrace.io' },
};

let currentChainId = 1;

/** Pending approval requests waiting for user action in popup */
const pendingApprovals = new Map<string, {
  request: ApprovalRequest;
  resolve: (result: unknown) => void;
  reject: (error: unknown) => void;
}>();

/** Max age for pending approvals (5 minutes) — prevents memory leaks on SW restart */
const APPROVAL_TTL_MS = 5 * 60 * 1000;

/** Prune stale approvals */
function pruneStaleApprovals(): void {
  const now = Date.now();
  for (const [id, entry] of pendingApprovals) {
    if (now - entry.request.timestamp > APPROVAL_TTL_MS) {
      entry.reject('Request expired');
      pendingApprovals.delete(id);
    }
  }
}

/** Get current chain ID as hex */
export function getCurrentChainIdHex(): string {
  return '0x' + currentChainId.toString(16);
}

/** Get current network config */
export function getCurrentNetwork(): NetworkConfig {
  return NETWORKS[currentChainId] || NETWORKS[1];
}

/** Route an incoming RPC request from a DApp */
export async function handleRequest(
  request: RpcRequest,
  origin: string,
): Promise<{ result?: unknown; error?: { code: number; message: string } }> {
  const { method, params } = request;

  // Security check — block phishing origins
  if (isPhishing(origin)) {
    return { error: { code: 4100, message: 'Blocked: known phishing site' } };
  }

  switch (method) {
    // ── Local fast methods ──
    case 'eth_chainId':
      return { result: getCurrentChainIdHex() };

    case 'net_version':
      return { result: String(currentChainId) };

    case 'eth_accounts':
    case 'eth_requestAccounts':
      return { result: keyring.getAccounts() };

    case 'eth_coinbase':
      const accounts = keyring.getAccounts();
      return { result: accounts.length > 0 ? accounts[0] : null };

    case 'wallet_requestPermissions':
    case 'wallet_getPermissions':
      return {
        result: [{
          parentCapability: 'eth_accounts',
          caveats: [{ type: 'restrictReturnedAccounts', value: keyring.getAccounts() }],
        }],
      };

    case 'web3_clientVersion':
      return { result: 'N42Wallet/1.0.0' };

    case 'wallet_watchAsset':
      return { result: true };

    // ── Chain switching ──
    case 'wallet_switchEthereumChain': {
      const chainIdHex = (params as any[])?.[0]?.chainId;
      if (!chainIdHex) return { error: { code: -32602, message: 'Missing chainId' } };
      const chainId = parseInt(chainIdHex, 16);
      if (!NETWORKS[chainId]) {
        return { error: { code: 4902, message: 'Unrecognized chain ID' } };
      }
      currentChainId = chainId;
      // Notify all tabs
      broadcastEvent('chainChanged', getCurrentChainIdHex());
      return { result: null };
    }

    // ── Signing (requires popup approval) ──
    case 'personal_sign':
    case 'eth_sign':
    case 'eth_signTypedData':
    case 'eth_signTypedData_v3':
    case 'eth_signTypedData_v4':
      return requestApproval({
        type: 'sign_message',
        origin,
        method,
        params,
      });

    case 'eth_sendTransaction':
      return requestApproval({
        type: 'sign_transaction',
        origin,
        method,
        params,
      });

    case 'eth_signTransaction':
      return requestApproval({
        type: 'sign_transaction',
        origin,
        method,
        params,
      });

    // ── RPC passthrough ──
    case 'eth_call':
    case 'eth_estimateGas':
    case 'eth_getBalance':
    case 'eth_getTransactionCount':
    case 'eth_getTransactionReceipt':
    case 'eth_getTransactionByHash':
    case 'eth_getBlockByNumber':
    case 'eth_getBlockByHash':
    case 'eth_blockNumber':
    case 'eth_gasPrice':
    case 'eth_getCode':
    case 'eth_getLogs':
    case 'eth_getStorageAt':
    case 'eth_maxPriorityFeePerGas':
    case 'eth_feeHistory':
      return forwardToRpc(method, params);

    default:
      // Try forwarding unknown methods to RPC
      return forwardToRpc(method, params);
  }
}

/** Forward a request to the current chain's RPC endpoint */
async function forwardToRpc(
  method: string,
  params: unknown,
): Promise<{ result?: unknown; error?: { code: number; message: string } }> {
  const network = getCurrentNetwork();
  try {
    const resp = await fetch(network.rpcUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method,
        params,
      }),
    });
    const json = await resp.json();
    if (json.error) {
      return { error: { code: json.error.code, message: json.error.message } };
    }
    return { result: json.result };
  } catch (e) {
    return { error: { code: -32603, message: `RPC error: ${e}` } };
  }
}

/** Request user approval via popup */
async function requestApproval(request: Omit<ApprovalRequest, 'id' | 'timestamp'>): Promise<{ result?: unknown; error?: { code: number; message: string } }> {
  if (!keyring.isUnlocked()) {
    return { error: { code: 4100, message: 'Wallet is locked' } };
  }

  const id = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  const approval: ApprovalRequest = {
    ...request,
    id,
    timestamp: Date.now(),
  };

  // Clean up stale approvals before adding new one
  pruneStaleApprovals();

  return new Promise((resolve) => {
    pendingApprovals.set(id, {
      request: approval,
      resolve: (result) => resolve({ result }),
      reject: (error) => resolve({ error: { code: 4001, message: String(error) } }),
    });

    // Open popup for approval
    chrome.action.openPopup?.().catch(() => {
      // Fallback: create a window
      chrome.windows.create({
        url: chrome.runtime.getURL(`popup.html?approval=${id}`),
        type: 'popup',
        width: 380,
        height: 620,
      });
    });
  });
}

/** Get pending approvals (called by popup) */
export function getPendingApprovals(): ApprovalRequest[] {
  return Array.from(pendingApprovals.values()).map((p) => p.request);
}

/** Approve a pending request (called by popup) */
export async function approveRequest(id: string): Promise<void> {
  const pending = pendingApprovals.get(id);
  if (!pending) return;

  try {
    const { request } = pending;
    let result: unknown;

    if (request.type === 'sign_message') {
      const accounts = keyring.getAccounts();
      if (accounts.length === 0) throw new Error('No accounts');
      // personal_sign params: [message, address]
      const message = (request.params as string[])[0];
      result = keyring.signPersonalMessage(0, message);
    } else if (request.type === 'sign_transaction') {
      // For now, return placeholder — full tx signing requires nonce/gas estimation
      result = '0x'; // TODO: implement full transaction signing
    }

    pending.resolve(result);
  } catch (e) {
    pending.reject(e);
  } finally {
    pendingApprovals.delete(id);
  }
}

/** Reject a pending request (called by popup) */
export function rejectRequest(id: string): void {
  const pending = pendingApprovals.get(id);
  if (!pending) return;
  pending.reject('User rejected');
  pendingApprovals.delete(id);
}

/** Broadcast an event to all content scripts */
function broadcastEvent(event: string, data: unknown): void {
  chrome.tabs.query({}, (tabs) => {
    for (const tab of tabs) {
      if (tab.id) {
        chrome.tabs.sendMessage(tab.id, {
          type: 'N42_EVENT',
          payload: { event, data },
        }).catch(() => {});
      }
    }
  });
}
