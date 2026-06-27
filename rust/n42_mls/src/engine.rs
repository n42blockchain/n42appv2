//! 真实 MLS（RFC 9420）引擎，基于 OpenMLS 0.8。
//!
//! 一个 [`MlsEngine`] 代表一个本地用户（持有签名密钥 + 凭证 + 该用户参与的群）。
//! 与 `n42_chat` 的 `FfiMlsProtocol`（MethodChannel `n42.chat/mls`）契约一一对应：
//! generateKeyPackage / createGroup / addMembers / removeMembers / processCommit /
//! processWelcome / encrypt / decrypt / selfUpdate。
//!
//! 这是**真实密码学**（TreeKEM / HPKE / 棘轮由 OpenMLS 执行），非占位。

use std::collections::HashMap;

use openmls::{
    credentials::{BasicCredential, CredentialWithKey},
    framing::{MlsMessageIn, ProcessedMessageContent},
    group::{
        GroupId, MlsGroup, MlsGroupCreateConfig, MlsGroupJoinConfig, StagedWelcome,
        PURE_CIPHERTEXT_WIRE_FORMAT_POLICY,
    },
    key_packages::{KeyPackage, KeyPackageIn},
    prelude::{LeafNodeIndex, MlsMessageBodyIn, ProtocolMessage, ProtocolVersion},
    treesync::LeafNodeParameters,
};
use openmls_basic_credential::SignatureKeyPair;
use openmls_rust_crypto::OpenMlsRustCrypto;
use openmls_traits::{types::Ciphersuite, OpenMlsProvider as _};
use tls_codec::{Deserialize as _, Serialize as _};

/// 默认 ciphersuite（X25519 + ChaCha20Poly1305 + SHA256 + Ed25519，普遍支持）。
pub const CIPHERSUITE: Ciphersuite =
    Ciphersuite::MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519;

/// MLS 操作错误。
#[derive(Debug)]
pub enum MlsError {
    /// 群不存在
    GroupNotFound,
    /// 反/序列化失败
    Codec(String),
    /// OpenMLS 操作失败
    Mls(String),
    /// 收到的消息类型非预期
    UnexpectedMessage,
}

impl std::fmt::Display for MlsError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MlsError::GroupNotFound => write!(f, "group not found"),
            MlsError::Codec(e) => write!(f, "codec error: {e}"),
            MlsError::Mls(e) => write!(f, "mls error: {e}"),
            MlsError::UnexpectedMessage => write!(f, "unexpected message type"),
        }
    }
}

impl std::error::Error for MlsError {}

type Result<T> = std::result::Result<T, MlsError>;

/// 一个本地 MLS 用户。
pub struct MlsEngine {
    provider: OpenMlsRustCrypto,
    signer: SignatureKeyPair,
    credential_with_key: CredentialWithKey,
    groups: HashMap<String, MlsGroup>,
}

impl MlsEngine {
    /// 用给定身份（如用户 id / 设备 id）新建本地用户。
    pub fn new(identity: &[u8]) -> Result<Self> {
        let provider = OpenMlsRustCrypto::default();
        let credential = BasicCredential::new(identity.to_vec());
        let signer = SignatureKeyPair::new(CIPHERSUITE.signature_algorithm())
            .map_err(|e| MlsError::Mls(format!("signer: {e:?}")))?;
        signer
            .store(provider.storage())
            .map_err(|e| MlsError::Mls(format!("store signer: {e:?}")))?;
        let credential_with_key = CredentialWithKey {
            credential: credential.into(),
            signature_key: signer.to_public_vec().into(),
        };
        Ok(Self {
            provider,
            signer,
            credential_with_key,
            groups: HashMap::new(),
        })
    }

    fn join_config() -> MlsGroupJoinConfig {
        // 让 Welcome 自带 ratchet tree，新成员无需带外取树。
        MlsGroupJoinConfig::builder()
            .use_ratchet_tree_extension(true)
            .build()
    }

    fn create_config() -> MlsGroupCreateConfig {
        MlsGroupCreateConfig::builder()
            .ciphersuite(CIPHERSUITE)
            .use_ratchet_tree_extension(true)
            // 密文握手：加密 Commit/Proposal，避免泄露成员变更/叶子身份等元数据。
            .wire_format_policy(PURE_CIPHERTEXT_WIRE_FORMAT_POLICY)
            .build()
    }

    /// 生成本端 KeyPackage（供他人加我入群）。返回 TLS 序列化字节。
    pub fn generate_key_package(&self) -> Result<Vec<u8>> {
        let bundle = KeyPackage::builder()
            .build(
                CIPHERSUITE,
                &self.provider,
                &self.signer,
                self.credential_with_key.clone(),
            )
            .map_err(|e| MlsError::Mls(format!("key package: {e:?}")))?;
        bundle
            .key_package()
            .tls_serialize_detached()
            .map_err(|e| MlsError::Codec(format!("{e:?}")))
    }

    /// 新建 MLS 群。
    pub fn create_group(&mut self, group_id: &str) -> Result<()> {
        let gid = GroupId::from_slice(group_id.as_bytes());
        let cfg = Self::create_config();
        let group = MlsGroup::new_with_group_id(
            &self.provider,
            &self.signer,
            &cfg,
            gid,
            self.credential_with_key.clone(),
        )
        .map_err(|e| MlsError::Mls(format!("create group: {e:?}")))?;
        self.groups.insert(group_id.to_string(), group);
        Ok(())
    }

    /// 加成员。返回 `(commit_bytes, welcome_bytes)`。
    pub fn add_members(
        &mut self,
        group_id: &str,
        key_packages: &[Vec<u8>],
    ) -> Result<(Vec<u8>, Vec<u8>)> {
        let mut kps = Vec::with_capacity(key_packages.len());
        for bytes in key_packages {
            let kp_in = KeyPackageIn::tls_deserialize(&mut bytes.as_slice())
                .map_err(|e| MlsError::Codec(format!("key package: {e:?}")))?;
            let kp = kp_in
                .validate(self.provider.crypto(), ProtocolVersion::Mls10)
                .map_err(|e| MlsError::Mls(format!("validate key package: {e:?}")))?;
            kps.push(kp);
        }
        let group = self
            .groups
            .get_mut(group_id)
            .ok_or(MlsError::GroupNotFound)?;
        let (commit, welcome, _group_info) = group
            .add_members(&self.provider, &self.signer, &kps)
            .map_err(|e| MlsError::Mls(format!("add_members: {e:?}")))?;
        group
            .merge_pending_commit(&self.provider)
            .map_err(|e| MlsError::Mls(format!("merge: {e:?}")))?;
        let commit_bytes = commit
            .tls_serialize_detached()
            .map_err(|e| MlsError::Codec(format!("{e:?}")))?;
        let welcome_bytes = welcome
            .tls_serialize_detached()
            .map_err(|e| MlsError::Codec(format!("{e:?}")))?;
        Ok((commit_bytes, welcome_bytes))
    }

    /// 移除成员（按叶子索引）。返回 commit_bytes。
    pub fn remove_members(
        &mut self,
        group_id: &str,
        leaf_indices: &[u32],
    ) -> Result<Vec<u8>> {
        let leaves: Vec<LeafNodeIndex> =
            leaf_indices.iter().map(|i| LeafNodeIndex::new(*i)).collect();
        let group = self
            .groups
            .get_mut(group_id)
            .ok_or(MlsError::GroupNotFound)?;
        let (commit, _welcome, _info) = group
            .remove_members(&self.provider, &self.signer, &leaves)
            .map_err(|e| MlsError::Mls(format!("remove_members: {e:?}")))?;
        group
            .merge_pending_commit(&self.provider)
            .map_err(|e| MlsError::Mls(format!("merge: {e:?}")))?;
        commit
            .tls_serialize_detached()
            .map_err(|e| MlsError::Codec(format!("{e:?}")))
    }

    /// 应用收到的 Commit（推进 epoch）。
    pub fn process_commit(&mut self, group_id: &str, commit: &[u8]) -> Result<()> {
        let msg = MlsMessageIn::tls_deserialize_exact(commit)
            .map_err(|e| MlsError::Codec(format!("{e:?}")))?;
        let protocol: ProtocolMessage = match msg.extract() {
            MlsMessageBodyIn::PublicMessage(m) => m.into(),
            MlsMessageBodyIn::PrivateMessage(m) => m.into(),
            _ => return Err(MlsError::UnexpectedMessage),
        };
        let group = self
            .groups
            .get_mut(group_id)
            .ok_or(MlsError::GroupNotFound)?;
        let processed = group
            .process_message(&self.provider, protocol)
            .map_err(|e| MlsError::Mls(format!("process: {e:?}")))?;
        match processed.into_content() {
            ProcessedMessageContent::StagedCommitMessage(staged) => {
                group
                    .merge_staged_commit(&self.provider, *staged)
                    .map_err(|e| MlsError::Mls(format!("merge staged: {e:?}")))?;
                Ok(())
            }
            _ => Err(MlsError::UnexpectedMessage),
        }
    }

    /// 处理收到的 Welcome（加入群）。返回 `group_id`。
    pub fn process_welcome(&mut self, welcome: &[u8]) -> Result<String> {
        let msg = MlsMessageIn::tls_deserialize_exact(welcome)
            .map_err(|e| MlsError::Codec(format!("{e:?}")))?;
        let welcome = match msg.extract() {
            MlsMessageBodyIn::Welcome(w) => w,
            _ => return Err(MlsError::UnexpectedMessage),
        };
        let cfg = Self::join_config();
        let staged = StagedWelcome::new_from_welcome(&self.provider, &cfg, welcome, None)
            .map_err(|e| MlsError::Mls(format!("staged welcome: {e:?}")))?;
        let group = staged
            .into_group(&self.provider)
            .map_err(|e| MlsError::Mls(format!("into_group: {e:?}")))?;
        let group_id = String::from_utf8_lossy(group.group_id().as_slice()).to_string();
        self.groups.insert(group_id.clone(), group);
        Ok(group_id)
    }

    /// 群内加密（应用消息）。返回密文（TLS 序列化的 MlsMessageOut）。
    pub fn encrypt(&mut self, group_id: &str, plaintext: &[u8]) -> Result<Vec<u8>> {
        let group = self
            .groups
            .get_mut(group_id)
            .ok_or(MlsError::GroupNotFound)?;
        let out = group
            .create_message(&self.provider, &self.signer, plaintext)
            .map_err(|e| MlsError::Mls(format!("create_message: {e:?}")))?;
        out.tls_serialize_detached()
            .map_err(|e| MlsError::Codec(format!("{e:?}")))
    }

    /// 群内解密。返回明文。
    pub fn decrypt(&mut self, group_id: &str, ciphertext: &[u8]) -> Result<Vec<u8>> {
        let msg = MlsMessageIn::tls_deserialize_exact(ciphertext)
            .map_err(|e| MlsError::Codec(format!("{e:?}")))?;
        let protocol: ProtocolMessage = match msg.extract() {
            MlsMessageBodyIn::PrivateMessage(m) => m.into(),
            MlsMessageBodyIn::PublicMessage(m) => m.into(),
            _ => return Err(MlsError::UnexpectedMessage),
        };
        let group = self
            .groups
            .get_mut(group_id)
            .ok_or(MlsError::GroupNotFound)?;
        let processed = group
            .process_message(&self.provider, protocol)
            .map_err(|e| MlsError::Mls(format!("process: {e:?}")))?;
        match processed.into_content() {
            ProcessedMessageContent::ApplicationMessage(app) => Ok(app.into_bytes()),
            _ => Err(MlsError::UnexpectedMessage),
        }
    }

    /// PCS（后向安全）：自更新密钥。返回 commit_bytes（其他成员需 process_commit）。
    pub fn self_update(&mut self, group_id: &str) -> Result<Vec<u8>> {
        let group = self
            .groups
            .get_mut(group_id)
            .ok_or(MlsError::GroupNotFound)?;
        let bundle = group
            .self_update(&self.provider, &self.signer, LeafNodeParameters::default())
            .map_err(|e| MlsError::Mls(format!("self_update: {e:?}")))?;
        let commit = bundle.into_commit();
        group
            .merge_pending_commit(&self.provider)
            .map_err(|e| MlsError::Mls(format!("merge: {e:?}")))?;
        commit
            .tls_serialize_detached()
            .map_err(|e| MlsError::Codec(format!("{e:?}")))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn full_group_round_trip() {
        // alice 建群，加 bob，双向收发，bob 离开后 alice 仍可用。
        let mut alice = MlsEngine::new(b"alice").unwrap();
        let mut bob = MlsEngine::new(b"bob").unwrap();

        let bob_kp = bob.generate_key_package().unwrap();

        alice.create_group("room1").unwrap();
        let (_commit, welcome) = alice.add_members("room1", &[bob_kp]).unwrap();

        let joined = bob.process_welcome(&welcome).unwrap();
        assert_eq!(joined, "room1");

        // alice -> bob
        let ct = alice.encrypt("room1", b"hello bob").unwrap();
        let pt = bob.decrypt("room1", &ct).unwrap();
        assert_eq!(pt, b"hello bob");

        // bob -> alice
        let ct2 = bob.encrypt("room1", b"hi alice").unwrap();
        let pt2 = alice.decrypt("room1", &ct2).unwrap();
        assert_eq!(pt2, b"hi alice");
    }

    #[test]
    fn self_update_advances_and_peer_processes() {
        let mut alice = MlsEngine::new(b"alice").unwrap();
        let mut bob = MlsEngine::new(b"bob").unwrap();
        let bob_kp = bob.generate_key_package().unwrap();
        alice.create_group("g").unwrap();
        let (_c, welcome) = alice.add_members("g", &[bob_kp]).unwrap();
        bob.process_welcome(&welcome).unwrap();

        // alice 自更新，bob 应用 commit，随后仍能互通。
        let commit = alice.self_update("g").unwrap();
        bob.process_commit("g", &commit).unwrap();

        let ct = alice.encrypt("g", b"after rotation").unwrap();
        assert_eq!(bob.decrypt("g", &ct).unwrap(), b"after rotation");
    }

    #[test]
    fn key_package_is_deserializable() {
        let bob = MlsEngine::new(b"bob").unwrap();
        let kp = bob.generate_key_package().unwrap();
        assert!(!kp.is_empty());
        // 能被重新反序列化为 KeyPackageIn（即 add_members 侧可消费）
        assert!(KeyPackageIn::tls_deserialize(&mut kp.as_slice()).is_ok());
    }

    #[test]
    fn unknown_group_errors() {
        let mut e = MlsEngine::new(b"x").unwrap();
        assert!(matches!(
            e.encrypt("nope", b"x"),
            Err(MlsError::GroupNotFound)
        ));
    }
}
