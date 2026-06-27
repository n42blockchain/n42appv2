# n42_mls — OpenMLS (RFC 9420) 后端

为 `n42_chat` 的群组加密提供**真实的 MLS（RFC 9420）密码学**。这是
`FfiMlsProtocol`（MethodChannel `n42.chat/mls`）背后真正执行 TreeKEM / HPKE /
棘轮的实现，基于成熟的 [OpenMLS](https://github.com/openmls/openmls) 0.8。

> **不在 Dart 手搓 MLS 密码学**（安全敏感、易错）。Dart 侧 `FfiMlsProtocol`
> 只做绑定/转发，真正的密码学在本 Rust crate。

## 已完成（本机已编译 + 测试验证）

- **`engine.rs`** — `MlsEngine`：一个本地用户，API 与 `FfiMlsProtocol` 契约一一
  对应：`generate_key_package` / `create_group` / `add_members` /
  `remove_members` / `process_commit` / `process_welcome` / `encrypt` /
  `decrypt` / `self_update`。Welcome 自带 ratchet tree（新成员无需带外取树）。
- **`ffi.rs`** — C ABI（`extern "C"`，见 `include/n42_mls.h`）：不透明引擎句柄 +
  只读输入切片 + `N42Buf` 出参 + 状态码；空指针/无效 UTF-8 安全返回错误码、不
  panic。
- **测试**：`cargo test` 6 个全绿——含 alice 建群→加 bob（KeyPackage+Welcome）→
  双向加解密、自更新（PCS）后对端处理 commit 仍可通信、**经 C ABI 的完整往返**、
  空指针安全。`cargo clippy` 零警告，`cargo build --release` 通过。

```bash
cd rust/n42_mls
cargo test            # 6 passed
cargo clippy --all-targets
```

## 待完成（移动端打包 + 接线 —— 需各平台工具链）

本 crate 的密码学已可用，剩下是把它编进 App 并接到 MethodChannel：

1. **Android**：`cargo-ndk` 交叉编译 `.so`（arm64-v8a / armeabi-v7a / x86_64）→
   放进 `android/app/src/main/jniLibs/`；写 JNI 包装把
   `n42.chat/mls` 的 MethodChannel 调用转成 `include/n42_mls.h` 的 C 调用。
   需 Android NDK + `rustup target add aarch64-linux-android ...`。
2. **iOS**：编 `staticlib`（`aarch64-apple-ios` + sim）打成 `.xcframework`；
   Swift 侧 bridging header 引 `n42_mls.h`，把 MethodChannel 转 C 调用。需 macOS。
3. **接线**：原生层在收到 `n42.chat/mls` 的 `isBound` 时返回 true（库已加载），
   其余方法转发到 C ABI；`FfiMlsProtocol.probe()` 即 isBound=true，MLS 启用。

> 真机/跨平台构建无法在当前 Windows 开发机完成（NDK/iOS 工具链），属基建任务。
> Dart 契约（`FfiMlsProtocol`）与本 crate 均已就绪，接线即生效。

## Ciphersuite

`MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519`（普遍支持）。
