use blst::{min_pk::SecretKey, BLST_ERROR};
use jni::{
    objects::{JClass, JString},
    sys::jboolean,
    JNIEnv,
};

fn decode_hex(input: &str) -> Option<Vec<u8>> {
    if input.len() % 2 != 0 {
        return None;
    }
    input
        .as_bytes()
        .chunks_exact(2)
        .map(|pair| {
            let high = (pair[0] as char).to_digit(16)? as u8;
            let low = (pair[1] as char).to_digit(16)? as u8;
            Some((high << 4) | low)
        })
        .collect()
}

fn verify_pair(secret_hex: &str, public_hex: &str) -> bool {
    let (Some(secret), Some(public)) = (decode_hex(secret_hex), decode_hex(public_hex)) else {
        return false;
    };
    let Ok(secret) = SecretKey::from_bytes(&secret) else {
        return false;
    };
    let derived = secret.sk_to_pk();
    if derived.to_bytes().as_slice() != public.as_slice() {
        return false;
    }

    // Synthetic fixture data only. A second message must fail under the same key/signature.
    let message = b"N42 offline MobileSdk BLS fixture";
    let domain = b"N42_ANDROID_TEST_BLS12381G2_XMD:SHA-256_SSWU_RO_";
    let signature = secret.sign(message, domain, &[]);
    signature.verify(true, message, domain, &[], &derived, true) == BLST_ERROR::BLST_SUCCESS
        && signature.verify(true, b"changed fixture", domain, &[], &derived, true)
            != BLST_ERROR::BLST_SUCCESS
}

#[no_mangle]
pub extern "system" fn Java_com_n42_android_1native_1smoke_BlsOracle_verifyPair(
    mut env: JNIEnv<'_>,
    _class: JClass<'_>,
    secret: JString<'_>,
    public: JString<'_>,
) -> jboolean {
    let Ok(secret) = env.get_string(&secret) else {
        return 0;
    };
    let Ok(public) = env.get_string(&public) else {
        return 0;
    };
    verify_pair(&secret.to_string_lossy(), &public.to_string_lossy()) as jboolean
}

#[cfg(test)]
mod tests {
    use super::verify_pair;
    use blst::min_pk::SecretKey;

    #[test]
    fn accepts_matching_pair_and_rejects_wrong_public_key() {
        let secret = SecretKey::key_gen(&[7u8; 32], &[]).unwrap();
        let other = SecretKey::key_gen(&[8u8; 32], &[]).unwrap();
        let secret_hex = secret
            .to_bytes()
            .iter()
            .map(|byte| format!("{byte:02x}"))
            .collect::<String>();
        let public_hex = secret
            .sk_to_pk()
            .to_bytes()
            .iter()
            .map(|byte| format!("{byte:02x}"))
            .collect::<String>();
        let other_hex = other
            .sk_to_pk()
            .to_bytes()
            .iter()
            .map(|byte| format!("{byte:02x}"))
            .collect::<String>();
        assert!(verify_pair(&secret_hex, &public_hex));
        assert!(!verify_pair(&secret_hex, &other_hex));
        assert!(!verify_pair("invalid", &public_hex));
    }
}
