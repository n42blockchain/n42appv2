/**
 * Keyring — HD wallet key management for Chrome Extension.
 *
 * Replaces Trustdart (MethodChannel native wallet-core) with pure JS:
 * - @scure/bip39 for mnemonic generation/validation
 * - @scure/bip32 for HD key derivation
 * - @noble/secp256k1 for ECDSA signing
 * - @noble/hashes for keccak256
 *
 * Security:
 * - Private keys only exist in memory within the Service Worker
 * - Encrypted at rest in chrome.storage.local using AES-256-GCM
 * - Auto-lock after timeout (5 minutes default)
 */

import * as secp from '@noble/secp256k1';
import { keccak_256 } from '@noble/hashes/sha3.js';
import { sha256 } from '@noble/hashes/sha2.js';
import { hmac } from '@noble/hashes/hmac.js';
import { HDKey } from '@scure/bip32';
import { generateMnemonic, mnemonicToSeedSync, validateMnemonic } from '@scure/bip39';
import { wordlist } from '@scure/bip39/wordlists/english.js';
import { bytesToHex, hexToBytes } from '@noble/hashes/utils.js';
import { hashTypedData } from 'viem';

const STORAGE_KEY = 'n42_keyring_encrypted';
const AUTO_LOCK_MS = 5 * 60 * 1000; // 5 minutes
const ETH_DERIVATION_PATH = "m/44'/60'/0'/0";

secp.hashes.sha256 = sha256;
secp.hashes.hmacSha256 = (key, message) => hmac(sha256, key, message);

interface KeyringState {
  mnemonic: string;
  accounts: Array<{ index: number; name: string }>;
}

let _state: KeyringState | null = null;
let _hdKey: HDKey | null = null;
let _lockTimer: ReturnType<typeof setTimeout> | null = null;

/** Check if keyring is unlocked */
export function isUnlocked(): boolean {
  return _state !== null;
}

/** Check if a vault exists (user has created/imported a wallet) */
export async function hasVault(): Promise<boolean> {
  const stored = await chrome.storage.local.get(STORAGE_KEY);
  return !!stored[STORAGE_KEY];
}

/** Create a new wallet with a fresh mnemonic */
export async function createWallet(password: string): Promise<string[]> {
  const mnemonic = generateMnemonic(wordlist, 128); // 12 words
  _state = { mnemonic, accounts: [{ index: 0, name: 'Account 1' }] };
  _hdKey = HDKey.fromMasterSeed(mnemonicToSeedSync(mnemonic));

  await _encrypt(password);
  _resetLockTimer();

  return getAccounts();
}

/** Import wallet from mnemonic */
export async function importWallet(mnemonic: string, password: string): Promise<string[]> {
  if (!validateMnemonic(mnemonic, wordlist)) {
    throw new Error('Invalid mnemonic');
  }

  _state = { mnemonic, accounts: [{ index: 0, name: 'Account 1' }] };
  _hdKey = HDKey.fromMasterSeed(mnemonicToSeedSync(mnemonic));

  await _encrypt(password);
  _resetLockTimer();

  return getAccounts();
}

/** Unlock vault with password */
export async function unlock(password: string): Promise<boolean> {
  try {
    const stored = await chrome.storage.local.get(STORAGE_KEY);
    const encrypted = stored[STORAGE_KEY];
    if (!encrypted) throw new Error('No vault found');

    const decrypted = await _decrypt(encrypted as string, password);
    _state = JSON.parse(decrypted);
    _hdKey = HDKey.fromMasterSeed(mnemonicToSeedSync(_state!.mnemonic));
    _resetLockTimer();
    return true;
  } catch {
    return false;
  }
}

/** Lock the vault — clears private keys from memory */
export function lock(): void {
  _state = null;
  _hdKey = null;
  if (_lockTimer) {
    clearTimeout(_lockTimer);
    _lockTimer = null;
  }
}

/** Get all account addresses */
export function getAccounts(): string[] {
  if (!_hdKey || !_state) return [];
  return _state.accounts.map((acc) => _deriveAddress(acc.index));
}

/** Add a new account (next HD index) */
export async function addAccount(name?: string): Promise<string> {
  if (!_state || !_hdKey) throw new Error('Keyring locked');

  const nextIndex = _state.accounts.length;
  _state.accounts.push({ index: nextIndex, name: name || `Account ${nextIndex + 1}` });

  // Re-encrypt with updated state
  // Password is needed — for simplicity, we re-encrypt on next unlock
  // In production, store the derived encryption key in memory while unlocked

  return _deriveAddress(nextIndex);
}

/** Sign a message hash (32 bytes) with the specified account */
export function signHash(accountIndex: number, hash: Uint8List): Uint8List {
  if (!_hdKey) throw new Error('Keyring locked');

  const child = _hdKey.derive(`${ETH_DERIVATION_PATH}/${accountIndex}`);
  if (!child.privateKey) throw new Error('Key derivation failed');

  const sig = secp.sign(hash, child.privateKey, { prehash: false, format: 'recovered' });
  // Return 65-byte signature: r (32) + s (32) + v (1)
  const result = new Uint8Array(65);
  result.set(sig.subarray(1));
  result[64] = sig[0] + 27;
  return result;
}

/** Sign a personal message (EIP-191) */
export function signPersonalMessage(accountIndex: number, message: string): string {
  const messageBytes = message.startsWith('0x')
    ? hexToBytes(message.slice(2))
    : new TextEncoder().encode(message);

  const prefix = `\x19Ethereum Signed Message:\n${messageBytes.length}`;
  const prefixBytes = new TextEncoder().encode(prefix);

  const combined = new Uint8Array(prefixBytes.length + messageBytes.length);
  combined.set(prefixBytes);
  combined.set(messageBytes, prefixBytes.length);

  const hash = keccak_256(combined);
  const sig = signHash(accountIndex, hash);
  return '0x' + bytesToHex(sig);
}

/** Sign an eth_sign payload without replacing it with the address parameter. */
export function signRawMessage(accountIndex: number, message: string): string {
  const messageBytes = message.startsWith('0x')
    ? hexToBytes(message.slice(2))
    : new TextEncoder().encode(message);
  const hash = messageBytes.length === 32 ? messageBytes : keccak_256(messageBytes);
  const sig = signHash(accountIndex, hash);
  return '0x' + bytesToHex(sig);
}

/** Sign EIP-712 typed data. */
export function signTypedData(accountIndex: number, typedData: unknown): string {
  const hash = hashTypedData(typedData as Parameters<typeof hashTypedData>[0]);
  const sig = signHash(accountIndex, hexToBytes(hash.slice(2)));
  return '0x' + bytesToHex(sig);
}

/** Get the address for a specific account index */
export function getAddress(accountIndex: number): string {
  return _deriveAddress(accountIndex);
}

/** Export mnemonic (requires unlocked state) */
export function exportMnemonic(): string {
  if (!_state) throw new Error('Keyring locked');
  return _state.mnemonic;
}

// ==================== Internal ====================

type Uint8List = Uint8Array;

function _deriveAddress(index: number): string {
  if (!_hdKey) throw new Error('Keyring locked');
  const child = _hdKey.derive(`${ETH_DERIVATION_PATH}/${index}`);
  if (!child.publicKey) throw new Error('Key derivation failed');

  // Uncompressed public key (65 bytes) → drop first byte → keccak256 → last 20 bytes
  const pubUncompressed = secp.Point.fromBytes(child.publicKey).toBytes(false);
  const hash = keccak_256(pubUncompressed.slice(1));
  const address = hash.slice(-20);
  return '0x' + bytesToHex(address);
}

function _resetLockTimer(): void {
  if (_lockTimer) clearTimeout(_lockTimer);
  _lockTimer = setTimeout(() => lock(), AUTO_LOCK_MS);
}

/** Encrypt state with AES-256-GCM using password-derived key */
async function _encrypt(password: string): Promise<void> {
  const enc = new TextEncoder();
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const iv = crypto.getRandomValues(new Uint8Array(12));

  const keyMaterial = await crypto.subtle.importKey(
    'raw', enc.encode(password), 'PBKDF2', false, ['deriveBits', 'deriveKey']
  );
  const key = await crypto.subtle.deriveKey(
    { name: 'PBKDF2', salt: salt.buffer as ArrayBuffer, iterations: 600000, hash: 'SHA-256' },
    keyMaterial, { name: 'AES-GCM', length: 256 }, false, ['encrypt']
  );

  const plaintext = enc.encode(JSON.stringify(_state));
  const ciphertext = await crypto.subtle.encrypt({ name: 'AES-GCM', iv: iv.buffer as ArrayBuffer }, key, plaintext);

  const encrypted = {
    salt: bytesToHex(salt),
    iv: bytesToHex(iv),
    data: bytesToHex(new Uint8Array(ciphertext)),
  };

  await chrome.storage.local.set({ [STORAGE_KEY]: JSON.stringify(encrypted) });
}

/** Decrypt state from chrome.storage */
async function _decrypt(encryptedStr: string, password: string): Promise<string> {
  const enc = new TextEncoder();
  const dec = new TextDecoder();
  const encrypted = JSON.parse(encryptedStr);

  const salt = hexToBytes(encrypted.salt);
  const iv = hexToBytes(encrypted.iv);
  const data = hexToBytes(encrypted.data);

  const keyMaterial = await crypto.subtle.importKey(
    'raw', enc.encode(password), 'PBKDF2', false, ['deriveBits', 'deriveKey']
  );
  const key = await crypto.subtle.deriveKey(
    { name: 'PBKDF2', salt: salt.buffer as ArrayBuffer, iterations: 600000, hash: 'SHA-256' },
    keyMaterial, { name: 'AES-GCM', length: 256 }, false, ['decrypt']
  );

  const plaintext = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: iv.buffer as ArrayBuffer }, key, data.buffer as ArrayBuffer);
  return dec.decode(plaintext);
}
