// Run with NODE_PATH pointing to an isolated @multiversx/sdk-core@16.0.0 install.
// Synthetic signatures test serialization, not signature validity or broadcast.
const { Address, Transaction, TransactionComputer } = require('@multiversx/sdk-core');
const { version } = require('@multiversx/sdk-core/package.json');
if (version !== '16.0.0') throw new Error('Use sdk-core 16.0.0');
const sender = new Address(new Uint8Array(32).fill(1));
const receiver = new Address(new Uint8Array(32).fill(2));
const rows = [
  ['ordinary', {}],
  ['zero', {nonce: 0n, value: 0n}],
  ['large-value', {value: 100000000000000000001n}],
  ['unicode-data', {data: Buffer.from('会议 🦊')}],
  ['testnet', {chainID: 'T'}],
  ['devnet', {chainID: 'D'}],
  ['nonce-varint', {nonce: 16384n}],
  ['hash-sign-option', {version: 2, options: 1}],
  ['different-signature', {signature: new Uint8Array(64).fill(5)}],
  ['different-sender', {sender: receiver, receiver: sender}],
  ['max-safe-integer', {nonce: 9007199254740991n, gasLimit: 9007199254740991n}],
].map(([name, overrides]) => {
  const tx = new Transaction({sender, receiver, nonce: 7n, value: 1000000000000000000n,
    gasPrice: 1000000000n, gasLimit: 50000n, chainID: '1', version: 1,
    signature: new Uint8Array(64).fill(3), ...overrides});
  return {name, transaction: tx.toPlainObject(), hash: new TransactionComputer().computeTransactionHash(tx)};
});
process.stdout.write(JSON.stringify({sdk: '@multiversx/sdk-core@' + version, vectors: rows}, null, 2) + '\n');
