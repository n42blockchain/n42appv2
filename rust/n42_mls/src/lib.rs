//! n42_mls — OpenMLS (RFC 9420) 后端
//!
//! 为 `n42_chat` 的 `FfiMlsProtocol`（MethodChannel `n42.chat/mls`）提供真实的
//! MLS 群组加密。`engine` 是纯 Rust 引擎（可 `cargo test`）；移动端原生插件
//! （Android JNI / iOS）经 C ABI 调用，再桥接到 MethodChannel。

pub mod engine;
pub mod ffi;

#[cfg(target_os = "android")]
mod android_jni;

pub use engine::{MlsEngine, MlsError, CIPHERSUITE};

pub fn version() -> &'static str {
    env!("CARGO_PKG_VERSION")
}
