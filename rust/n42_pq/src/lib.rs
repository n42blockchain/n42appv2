//! PQClean Falcon-512, independent from the node's experimental Go verifier.
use pqcrypto_falcon::falconpadded512 as f;
use pqcrypto_traits::sign::{DetachedSignature, PublicKey, SecretKey};
use std::slice;
mod key_validation;

/// Callers provide writable buffers of exactly the documented sizes.
#[no_mangle]
pub unsafe extern "C" fn n42_pq_keypair(pk: *mut u8, sk: *mut u8) -> i32 {
    if pk.is_null() || sk.is_null() {
        return -1;
    }
    let (p, s) = f::keypair();
    std::ptr::copy_nonoverlapping(p.as_bytes().as_ptr(), pk, f::public_key_bytes());
    std::ptr::copy_nonoverlapping(s.as_bytes().as_ptr(), sk, f::secret_key_bytes());
    0
}
#[no_mangle]
pub unsafe extern "C" fn n42_pq_sign(sk: *const u8, msg: *const u8, sig: *mut u8) -> i32 {
    if sk.is_null() || msg.is_null() || sig.is_null() {
        return -1;
    }
    if !key_validation::valid(slice::from_raw_parts(sk, f::secret_key_bytes())) {
        return -1;
    }
    let Ok(key) = f::SecretKey::from_bytes(slice::from_raw_parts(sk, f::secret_key_bytes())) else {
        return -1;
    };
    let signed = f::detached_sign(slice::from_raw_parts(msg, 32), &key);
    let b = signed.as_bytes();
    std::ptr::copy_nonoverlapping(b.as_ptr(), sig, b.len());
    b.len() as i32
}
#[no_mangle]
pub unsafe extern "C" fn n42_pq_verify(
    pk: *const u8,
    msg: *const u8,
    sig: *const u8,
    len: usize,
) -> i32 {
    if pk.is_null() || msg.is_null() || sig.is_null() || len == 0 || len > f::signature_bytes() {
        return -1;
    }
    let Ok(key) = f::PublicKey::from_bytes(slice::from_raw_parts(pk, f::public_key_bytes())) else {
        return -1;
    };
    let Ok(signature) = f::DetachedSignature::from_bytes(slice::from_raw_parts(sig, len)) else {
        return -1;
    };
    if f::verify_detached_signature(&signature, slice::from_raw_parts(msg, 32), &key).is_ok() {
        0
    } else {
        -1
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn real_signatures_bind_key_and_message() {
        let (p, s) = f::keypair();
        assert!(key_validation::valid(s.as_bytes()));
        assert!(!key_validation::valid(&[0u8; 1281]));
        let (q, _) = f::keypair();
        let msg = [7u8; 32];
        let sig = f::detached_sign(&msg, &s);
        assert!(f::verify_detached_signature(&sig, &msg, &p).is_ok());
        assert!(f::verify_detached_signature(&sig, &[8u8; 32], &p).is_err());
        assert!(f::verify_detached_signature(&sig, &msg, &q).is_err());
        assert_eq!(p.as_bytes().len(), 897);
        assert_eq!(s.as_bytes().len(), 1281);
    }
}
