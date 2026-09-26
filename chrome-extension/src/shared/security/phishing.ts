/**
 * Phishing URL detection — ported from lib/core/security/phishing_detector.dart
 *
 * Three-layer protection:
 * 1. Embedded seed blocklist (immediate, no I/O)
 * 2. chrome.storage.local cache (survives restarts)
 * 3. MetaMask eth-phishing-detect remote refresh (every 6 hours)
 */

const REMOTE_URL =
  'https://raw.githubusercontent.com/MetaMask/eth-phishing-detect/master/src/config.json';
const CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6 hours
const STORAGE_KEY = 'phishing_blocklist_v1';

/** Seed blocklist — most prevalent crypto phishing domains */
const SEED_BLOCKLIST: string[] = [
  'metamask-login.com', 'metamask-wallet.com', 'metamask-support.com',
  'metamask.io.live', 'myetherwallet.xyz', 'myetherwallet.us',
  'wallet-connect.live', 'walletconnect.io.live', 'walletconnect-app.com',
  'uniswap.exchange.live', 'uniswap.org.live',
  'pancakeswap.finance.live', 'pancakeswap-farm.com',
  'airdrop-claim.xyz', 'crypto-airdrop.io',
  'claim-nft.xyz', 'nft-claim.live', 'nft-airdrop.xyz',
  'wallet-recovery.net', 'coinbase-wallet.live',
  'trustwallet.live', 'trustwallet-app.com',
  'opensea-io.live', 'opensea.io.live', 'etherscan.io.live',
  'connect-wallet.live', 'connect-metamask.io',
  'claim-reward.live', 'crypto-claim.xyz', 'defi-airdrop.xyz',
  'metamask-io.com', 'metamask-io.net', 'metamaskwallet.io',
];

let blocklist: Set<string> = new Set(SEED_BLOCKLIST);
let whitelist: Set<string> = new Set();
let lastFetch = 0;

/** Initialize — loads cache and optionally refreshes from remote */
export async function initPhishingDetector(): Promise<void> {
  try {
    const stored = await chrome.storage.local.get(STORAGE_KEY);
    if (stored[STORAGE_KEY]) {
      const { domains, whitelistDomains, timestamp } = stored[STORAGE_KEY] as {
        domains?: string[];
        whitelistDomains?: string[];
        timestamp?: number;
      };
      if (Array.isArray(domains)) {
        blocklist = new Set([...SEED_BLOCKLIST, ...domains]);
      }
      if (Array.isArray(whitelistDomains)) {
        whitelist = new Set(whitelistDomains);
      }
      lastFetch = timestamp || 0;
    }
  } catch { /* use seed list */ }

  if (Date.now() - lastFetch > CACHE_TTL_MS) {
    refreshFromRemote().catch(() => {});
  }
}

/** Check if a URL is a known phishing site */
export function isPhishing(url: string): boolean {
  try {
    const host = new URL(url).hostname.toLowerCase();
    if (whitelist.has(host)) return false;
    if (blocklist.has(host)) return true;
    // Check parent domains
    const parts = host.split('.');
    for (let i = 1; i < parts.length - 1; i++) {
      const parent = parts.slice(i).join('.');
      if (blocklist.has(parent)) return true;
    }
    return false;
  } catch {
    return false;
  }
}

async function refreshFromRemote(): Promise<void> {
  try {
    const resp = await fetch(REMOTE_URL, { signal: AbortSignal.timeout(10000) });
    if (!resp.ok) return;
    const data = await resp.json();
    const remoteDomains: string[] = data.blacklist || [];
    const remoteWhitelist: string[] = data.whitelist || [];

    blocklist = new Set([...SEED_BLOCKLIST, ...remoteDomains]);
    whitelist = new Set(remoteWhitelist);
    lastFetch = Date.now();

    await chrome.storage.local.set({
      [STORAGE_KEY]: {
        domains: remoteDomains,
        whitelistDomains: remoteWhitelist,
        timestamp: lastFetch,
      },
    });
  } catch { /* silent fail */ }
}
