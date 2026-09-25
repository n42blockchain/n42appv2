import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { hexToBytes, keccak256, recoverAddress, recoverMessageAddress, recoverTypedDataAddress, stringToBytes } from 'viem';
import {
  addAccount,
  exportMnemonic,
  getAccounts,
  getAddress,
  hasVault,
  importWallet,
  isUnlocked,
  lock,
  signHash,
  signPersonalMessage,
  signRawMessage,
  signTypedData,
  unlock,
} from './keyring';

const MNEMONIC = 'test test test test test test test test test test test junk';
const ADDRESS_0 = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
const ADDRESS_1 = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8';
const PASSWORD = 'test-password';
// Reference signatures from viem's mnemonicToAccount signer, independent of keyring.signHash.
const PERSONAL_SIGNATURE = '0x9f5be2813eaf08cc7b287c7c4fb29349e399982cb0c9340127e1588a107f20ed509a531ab2271604514d93205bf785859a36ad3adb479a8b246fe75ec195cbf81c';
const RAW_SIGNATURE = '0xcdb500762ac58d2080ffc4232583dcc77b12800d2c496cc56fedcbd0160b643d7189d5ef16dbf542264e7a526bced5dbb4becf938f6098f8e507124f8bd3e1ba1c';
const TYPED_SIGNATURE = '0x9f1e112c6fd60383c664d0fb4f1ea29964bf25b73b3c0657a408c0393b960d16168c97ffbdd4e978c75b02fcc0dc5ea126188c7648a872a5f4c0e92eb0e44aeb1b';

beforeEach(() => lock());
afterEach(() => lock());

describe('HD keyring', () => {
  it('derives the standard mnemonic at account indexes 0 and 1', async () => {
    expect(await importWallet(MNEMONIC, PASSWORD)).toEqual([ADDRESS_0.toLowerCase()]);
    expect(await hasVault()).toBe(true);
    expect(await addAccount()).toBe(ADDRESS_1.toLowerCase());
    expect(getAccounts()).toEqual([ADDRESS_0.toLowerCase(), ADDRESS_1.toLowerCase()]);
    expect(getAddress(1)).toBe(ADDRESS_1.toLowerCase());
  });

  it('recovers a personal message signature to the derived address', async () => {
    await importWallet(MNEMONIC, PASSWORD);
    const signature = signPersonalMessage(0, 'hello n42') as `0x${string}`;
    expect(signature).toBe(PERSONAL_SIGNATURE);
    expect(signature).toMatch(/^0x[0-9a-f]{130}$/);
    expect([27, 28]).toContain(hexToBytes(signature)[64]);
    expect(await recoverMessageAddress({ message: 'hello n42', signature })).toBe(ADDRESS_0);
  });

  it('recovers raw hash and eth_sign payload signatures to the derived address', async () => {
    await importWallet(MNEMONIC, PASSWORD);
    const hash = keccak256(stringToBytes('n42 raw signing vector'));
    const direct = `0x${Buffer.from(signHash(0, hexToBytes(hash))).toString('hex')}` as `0x${string}`;
    const raw = signRawMessage(0, hash) as `0x${string}`;
    expect(raw).toBe(RAW_SIGNATURE);
    expect(raw).toBe(direct);
    expect(await recoverAddress({ hash, signature: raw })).toBe(ADDRESS_0);
  });

  it('recovers an EIP-712 signature to the derived address', async () => {
    await importWallet(MNEMONIC, PASSWORD);
    const typedData = {
      domain: { name: 'N42', version: '1', chainId: 1 },
      primaryType: 'Message',
      types: { Message: [{ name: 'contents', type: 'string' }] },
      message: { contents: 'hello n42' },
    } as const;
    const signature = signTypedData(0, typedData) as `0x${string}`;
    expect(signature).toBe(TYPED_SIGNATURE);
    expect(await recoverTypedDataAddress({ ...typedData, signature })).toBe(ADDRESS_0);
  });

  it('clears signing material on lock and rejects a wrong password', async () => {
    await importWallet(MNEMONIC, PASSWORD);
    lock();
    expect(isUnlocked()).toBe(false);
    expect(getAccounts()).toEqual([]);
    expect(() => signHash(0, new Uint8Array(32))).toThrow('Keyring locked');
    expect(() => exportMnemonic()).toThrow('Keyring locked');
    expect(await unlock('wrong-password')).toBe(false);
    expect(isUnlocked()).toBe(false);
    expect(await unlock(PASSWORD)).toBe(true);
    expect(getAddress(0)).toBe(ADDRESS_0.toLowerCase());
  });
});
