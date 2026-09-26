#[cfg(test)]
mod tests {
    use blst::{min_pk::SecretKey, BLST_ERROR};
    use sha3::{Digest, Keccak256};

    const DST: &[u8] = b"BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_POP_";
    const LOW_PUBLIC: &str = "850e1b31deb8cf7202b3a060f79ba72d107688cda71f2fa78016c29395e148cb192904c7dfa7d64a2a09b7c95ef5168b";
    const LOW_SIGNATURE: &str = "ae57498fe373727aa21011bcc2debacbb09ed69c93bac38848752fa9f60f750d942e1fde6ec94bc819e4d6da6b3dac7419ad5b87e7ffefe74fa0fa321ca281b1add3967c6666025ef9ebedc39bd71058a05c76044b54cc79d4c934a488d30ce6";
    const HIGH_PUBLIC: &str = "b0aba28a81fe28a33e284f14ea83fea14f1803b46dfa5ff88766dd567f2d24ba181794e603ef8fdb43039af11d49b680";
    const HIGH_SIGNATURE: &str = "874a6a226f5585d820a6b8b76632a9ea4acf425c927ff599c961ec3ee669e4ab94fc14b6933b2e9003014f6906fcc8ba0b11e2998014c1e80dbf1e06015c864f643f7ad7484ace863b202851f4405d2a19d5716dd9693b74c30779bf2b1ddc00";

    fn hex(bytes: &[u8]) -> String {
        bytes.iter().map(|byte| format!("{byte:02x}")).collect()
    }

    fn amount_message() -> Vec<u8> {
        let wei = 10_u128 * 10_u128.pow(18);
        let big_endian = wei.to_be_bytes();
        let first = big_endian.iter().position(|byte| *byte != 0).unwrap();
        let message = big_endian[first..].to_vec();
        assert_eq!(hex(&message), "8ac7230489e80000");
        message
    }

    fn check_vector(ikm: [u8; 32], expected_public: &str, expected_signature: &str) {
        // This test uses the Rust blst 0.3.15 binding, separate from the Go
        // candidate's blst 0.3.17 binding and its Emit dispatcher.
        let secret = SecretKey::key_gen(&ikm, &[]).unwrap();
        let public = secret.sk_to_pk();
        let message = amount_message();
        let signature = secret.sign(&message, DST, &[]);
        assert_eq!(hex(&public.to_bytes()), expected_public);
        assert_eq!(hex(&signature.to_bytes()), expected_signature);
        assert_eq!(
            signature.verify(true, &message, DST, &[], &public, true),
            BLST_ERROR::BLST_SUCCESS
        );
        assert_ne!(
            signature.verify(true, b"changed offline amount", DST, &[], &public, true),
            BLST_ERROR::BLST_SUCCESS
        );
    }

    #[test]
    fn independent_low_and_high_bls_vectors() {
        let mut low = [0_u8; 32];
        low[31] = 1;
        check_vector(low, LOW_PUBLIC, LOW_SIGNATURE);
        check_vector([0xff; 32], HIGH_PUBLIC, HIGH_SIGNATURE);
    }

    #[test]
    fn deposit_selector_and_dynamic_offsets() {
        let selector = Keccak256::digest(b"deposit(bytes,bytes)");
        assert_eq!(hex(&selector[..4]), "164af1df");
        // ABI head is two 32-byte offsets. A 48-byte public key occupies a
        // 32-byte length plus 64 padded data bytes, so signature starts at 160.
        let head_size = 2 * 32_usize;
        let public_tail_size = 32 + (LOW_PUBLIC.len() / 2).div_ceil(32) * 32;
        assert_eq!(head_size, 64);
        assert_eq!(head_size + public_tail_size, 160);
        assert_eq!(LOW_SIGNATURE.len() / 2, 96);
    }
}
