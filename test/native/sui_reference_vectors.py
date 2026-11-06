#!/usr/bin/env python3
"""Public deterministic Sui transaction-intent vectors, independent of WalletCore."""
import base64
import hashlib
import json
import struct
import subprocess

NODE = r"""
const c = require('node:crypto');
const input = JSON.parse(require('node:fs').readFileSync(0, 'utf8'));
const key = c.createPrivateKey({key:Buffer.concat([
  Buffer.from('302e020100300506032b657004220420','hex'), Buffer.from(input.seed,'hex')
]),format:'der',type:'pkcs8'});
const pub = c.createPublicKey(key).export({format:'der',type:'spki'}).subarray(-32);
const result = {pub:pub.toString('hex')};
if(input.digest) {
 const digest=Buffer.from(input.digest,'hex');
 const sig=c.sign(null,digest,key);
 if(!c.verify(null,digest,c.createPublicKey(key),sig)) throw Error('reference failed');
 result.signature=Buffer.concat([Buffer.from([0]),sig,pub]).toString('base64');
}
console.log(JSON.stringify(result));
"""

def node(data):
    return json.loads(subprocess.check_output(['node', '-e', NODE], input=json.dumps(data).encode()))

def vectors():
    result = []
    for seed_byte in [1, 2]:
        seed = bytes([seed_byte]) * 32
        pub = bytes.fromhex(node({'seed': seed.hex()})['pub'])
        sender = hashlib.blake2b(b'\x00' + pub, digest_size=32).digest()
        # TransactionData::V1, programmable transaction with no inputs/commands,
        # one synthetic gas object. This is an offline fixture, not a live object.
        raw = (bytes([0, 0, 0, 0]) + sender + bytes([1]) + bytes([3]) * 32 +
               struct.pack('<Q', 1) + bytes([32]) + bytes([4]) * 32 + sender +
               struct.pack('<QQ', 1000, 2_000_000) + bytes([0]))
        for payload in [raw, raw[:-9] + struct.pack('<Q', 3_000_000) + raw[-1:]]:
            digest = hashlib.blake2b(bytes([0, 0, 0]) + payload, digest_size=32).digest()
            signed = node({'seed': seed.hex(), 'digest': digest.hex()})
            result.append({'seed': seed.hex(), 'raw': base64.b64encode(payload).decode(),
                           'signature': signed['signature']})
    return result

if __name__ == '__main__':
    print(json.dumps(vectors()))
