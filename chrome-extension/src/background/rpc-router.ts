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
const ORIGIN_PERMISSIONS_KEY = 'n42_wallet_origin_permissions';

interface OriginPermissions {
  accounts: string[];
}

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
      return { result: await getAuthorizedAccounts(origin) };

    case 'eth_requestAccounts':
      if (!keyring.isUnlocked()) {
        return { error: { code: 4100, message: 'Wallet is locked' } };
      }
      return { result: await authorizeOriginAccounts(origin) };

    case 'eth_coinbase':
      const accounts = await getAuthorizedAccounts(origin);
      return { result: accounts.length > 0 ? accounts[0] : null };

    case 'wallet_getPermissions':
      return { result: buildAccountPermissions(await getAuthorizedAccounts(origin)) };

    case 'wallet_requestPermissions':
      if (!keyring.isUnlocked()) {
        return { error: { code: 4100, message: 'Wallet is locked' } };
      }
      return { result: buildAccountPermissions(await authorizeOriginAccounts(origin)) };

    case 'web3_clientVersion':
      return { result: 'N42Wallet/1.0.0' };

    case 'wallet_watchAsset':
      return { result: true };

    // ── Chain switching ──
    case 'wallet_switchEthereumChain': {
      const chainIdHex = (params?.[0] as { chainId?: string } | undefined)?.chainId;
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
    case 'eth_signTransaction':
      return {
        error: {
          code: 4200,
          message: `${method} is not supported by N42 Wallet extension yet`,
        },
      };

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
      result = signApprovedMessage(request.method, request.params);
    } else if (request.type === 'sign_transaction') {
      throw new Error(`${request.method} is not supported`);
    }

    pending.resolve(result);
  } catch (e) {
    pending.reject(e);
  } finally {
    pendingApprovals.delete(id);
  }
}

function signApprovedMessage(method: string, params: unknown): string {
  const values = Array.isArray(params) ? params : [];

  switch (method) {
    case 'personal_sign': {
      const { address, message } = extractPersonalSignParams(values);
      return keyring.signPersonalMessage(accountIndexForAddress(address), message);
    }
    case 'eth_sign': {
      const address = stringParam(values[0], 'address');
      const message = stringParam(values[1], 'message');
      return keyring.signRawMessage(accountIndexForAddress(address), message);
    }
    case 'eth_signTypedData':
    case 'eth_signTypedData_v3':
    case 'eth_signTypedData_v4': {
      const { address, typedData } = extractTypedDataParams(values);
      return keyring.signTypedData(accountIndexForAddress(address), typedData);
    }
    default:
      throw new Error(`Unsupported signing method: ${method}`);
  }
}

function extractPersonalSignParams(params: unknown[]): { address: string; message: string } {
  const first = stringParam(params[0], 'message');
  const second = stringParam(params[1], 'address');
  if (isOwnedAddress(second)) {
    return { address: second, message: first };
  }
  if (isOwnedAddress(first)) {
    return { address: first, message: second };
  }
  if (isAddress(second)) {
    return { address: second, message: first };
  }
  if (isAddress(first)) {
    return { address: first, message: second };
  }
  throw new Error('personal_sign request must include an account address');
}

function extractTypedDataParams(params: unknown[]): { address: string; typedData: unknown } {
  const first = params[0];
  const second = params[1];
  if (typeof first === 'string' && isAddress(first)) {
    return { address: first, typedData: parseTypedData(second) };
  }
  if (typeof second === 'string' && isAddress(second)) {
    return { address: second, typedData: parseTypedData(first) };
  }
  throw new Error('Typed data request must include an account address');
}

function parseTypedData(value: unknown): unknown {
  if (typeof value !== 'string') return value;
  try {
    return JSON.parse(value);
  } catch {
    throw new Error('Invalid typed data JSON');
  }
}

function stringParam(value: unknown, label: string): string {
  if (typeof value !== 'string' || value.length === 0) {
    throw new Error(`Missing ${label}`);
  }
  return value;
}

function isAddress(value: string): boolean {
  return /^0x[a-fA-F0-9]{40}$/.test(value);
}

function isOwnedAddress(value: string): boolean {
  if (!isAddress(value)) return false;
  return keyring.getAccounts().some(
    (account) => account.toLowerCase() === value.toLowerCase(),
  );
}

function accountIndexForAddress(address: string): number {
  const accounts = keyring.getAccounts();
  const index = accounts.findIndex(
    (account) => account.toLowerCase() === address.toLowerCase(),
  );
  if (index < 0) {
    throw new Error('Requested account is unavailable');
  }
  return index;
}

async function getAuthorizedAccounts(origin: string): Promise<string[]> {
  if (!keyring.isUnlocked()) return [];
  const permissions = await getOriginPermissions(origin);
  if (!permissions) return [];
  const availableAccounts = keyring.getAccounts();
  const available = new Set(availableAccounts.map((account) => account.toLowerCase()));
  return permissions.accounts.filter((account) => available.has(account.toLowerCase()));
}

async function authorizeOriginAccounts(origin: string): Promise<string[]> {
  const accounts = keyring.getAccounts();
  await setOriginPermissions(origin, { accounts });
  return accounts;
}

function buildAccountPermissions(accounts: string[]) {
  if (accounts.length === 0) return [];
  return [{
    parentCapability: 'eth_accounts',
    caveats: [{ type: 'restrictReturnedAccounts', value: accounts }],
  }];
}

async function getOriginPermissions(origin: string): Promise<OriginPermissions | null> {
  const allPermissions = await getAllOriginPermissions();
  return allPermissions[normalizeOrigin(origin)] ?? null;
}

async function setOriginPermissions(origin: string, permissions: OriginPermissions): Promise<void> {
  const allPermissions = await getAllOriginPermissions();
  allPermissions[normalizeOrigin(origin)] = permissions;
  await chrome.storage.local.set({ [ORIGIN_PERMISSIONS_KEY]: allPermissions });
}

async function getAllOriginPermissions(): Promise<Record<string, OriginPermissions>> {
  const stored = await chrome.storage.local.get(ORIGIN_PERMISSIONS_KEY);
  const value = stored[ORIGIN_PERMISSIONS_KEY];
  if (!value || typeof value !== 'object' || Array.isArray(value)) return {};
  return value as Record<string, OriginPermissions>;
}

function normalizeOrigin(origin: string): string {
  try {
    return new URL(origin).origin;
  } catch {
    return origin;
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
