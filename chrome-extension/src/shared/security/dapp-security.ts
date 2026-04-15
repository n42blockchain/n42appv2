/**
 * DApp Security Service — ported from lib/core/security/dapp_security_service.dart
 *
 * Four-level security assessment:
 * 1. PhishingDetector blocklist → blocked
 * 2. Curated trusted-domain list + HTTPS → verified
 * 3. HTTP → caution
 * 4. Suspicious patterns / risky TLDs → caution
 * 5. Otherwise → safe
 */

import { isPhishing } from './phishing';

export type SecurityLevel = 'verified' | 'safe' | 'caution' | 'blocked';

export interface SecurityInfo {
  level: SecurityLevel;
  reason?: string;
}

/** Trusted domains extracted from recommended_dapps.dart */
const TRUSTED_DOMAINS = new Set([
  // DEX
  'app.uniswap.org', 'uniswap.org', 'pancakeswap.finance',
  'app.1inch.io', '1inch.io', 'www.sushi.com', 'sushi.com', 'curve.fi',
  // DeFi
  'app.aave.com', 'aave.com', 'stake.lido.fi', 'lido.fi',
  'app.compound.finance', 'compound.finance', 'yearn.fi',
  'app.eigenlayer.xyz', 'eigenlayer.xyz',
  // NFT
  'opensea.io', 'blur.io', 'zora.co',
  // Bridge
  'stargate.finance', 'across.to', 'www.orbiter.finance', 'orbiter.finance',
  // Tools
  'etherscan.io', 'debank.com', 'revoke.cash', 'dune.com',
  // WalletConnect
  'walletconnect.com', 'reown.com',
]);

const SUSPICIOUS_PATTERNS = [
  /metamask/i, /wallet-connect/i,
  /(?:^|[.-])wallet(?:[.-]|$)/i, /(?:^|[.-])claim(?:[.-]|$)/i,
  /airdrop/i, /(?:^|[.-])login(?:[.-]|$)/i,
  /(?:^|[.-])secure(?:[.-]|$)/i, /(?:^|[.-])verify(?:[.-]|$)/i,
  /(?:^|[.-])support(?:[.-]|$)/i, /(?:^|[.-])recover(?:[.-]|$)/i,
];

const RISKY_TLD = /\.(xyz|live|click|monster|buzz|top|gq|ml|cf|ga|tk)$/i;

const cache = new Map<string, { info: SecurityInfo; at: number }>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

export function checkDAppSecurity(url: string): SecurityInfo {
  try {
    const parsed = new URL(url);
    const host = parsed.hostname.toLowerCase();

    // Cache hit
    const cached = cache.get(host);
    if (cached && Date.now() - cached.at < CACHE_TTL) return cached.info;

    // Evict old entries
    if (cache.size > 200) {
      for (const [k, v] of cache) {
        if (Date.now() - v.at > CACHE_TTL) cache.delete(k);
      }
    }

    let result: SecurityInfo;

    if (isPhishing(url)) {
      result = { level: 'blocked', reason: 'Known phishing site' };
    } else if (isTrusted(host) && parsed.protocol === 'https:') {
      result = { level: 'verified' };
    } else if (parsed.protocol !== 'https:') {
      result = { level: 'caution', reason: 'Not using HTTPS' };
    } else if (hasSuspiciousPattern(host) || RISKY_TLD.test(host)) {
      result = { level: 'caution', reason: 'Suspicious domain name' };
    } else {
      result = { level: 'safe' };
    }

    cache.set(host, { info: result, at: Date.now() });
    return result;
  } catch {
    return { level: 'caution', reason: 'Invalid URL' };
  }
}

function isTrusted(host: string): boolean {
  if (TRUSTED_DOMAINS.has(host)) return true;
  for (const d of TRUSTED_DOMAINS) {
    if (host.endsWith(`.${d}`)) return true;
  }
  return false;
}

function hasSuspiciousPattern(host: string): boolean {
  return SUSPICIOUS_PATTERNS.some((p) => p.test(host));
}
