//! C ABI 层 —— 供移动端原生插件（Android JNI / iOS）调用。
//!
//! 设计：不透明引擎句柄（`*mut MlsEngineHandle`）+ 输入只读切片（ptr,len）+
//! 输出经 [`N42Buf`] 出参（调用方用完须 [`n42_mls_buf_free`] 释放）。返回 i32
//! 状态码：0=成功，负数=错误。空指针/无效 utf-8 等均安全返回错误码，不 panic。
//!
//! 这是 `FfiMlsProtocol`（MethodChannel `n42.chat/mls`）背后真正执行 RFC 9420
//! 密码学的入口；原生层把 MethodChannel 调用翻译成本模块的 C 调用即可。

use std::os::raw::c_char;
use std::ptr;
use std::slice;

use crate::engine::MlsEngine;

/// 状态码
pub const N42_OK: i32 = 0;
pub const N42_ERR_NULL: i32 = -1;
pub const N42_ERR_UTF8: i32 = -2;
pub const N42_ERR_MLS: i32 = -3;

/// 返回给调用方的拥有所有权的字节缓冲（须经 [`n42_mls_buf_free`] 释放）。
#[repr(C)]
pub struct N42Buf {
    pub ptr: *mut u8,
    pub len: usize,
}

impl N42Buf {
    fn empty() -> Self {
        N42Buf {
            ptr: ptr::null_mut(),
            len: 0,
        }
    }

    fn from_vec(mut v: Vec<u8>) -> Self {
        v.shrink_to_fit();
        let len = v.len();
        let ptr = v.as_mut_ptr();
        std::mem::forget(v);
        N42Buf { ptr, len }
    }
}

/// 不透明引擎句柄
pub struct MlsEngineHandle {
    engine: MlsEngine,
}

unsafe fn as_slice<'a>(ptr: *const u8, len: usize) -> Option<&'a [u8]> {
    if ptr.is_null() {
        if len == 0 {
            return Some(&[]);
        }
        return None;
    }
    Some(slice::from_raw_parts(ptr, len))
}

unsafe fn as_str<'a>(ptr: *const u8, len: usize) -> Option<&'a str> {
    let bytes = as_slice(ptr, len)?;
    std::str::from_utf8(bytes).ok()
}

/// 新建引擎（本地用户）。失败返回 null。
///
/// # Safety
/// `identity_ptr` 须指向 `identity_len` 字节的有效内存（或 len=0 时可空）。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_engine_new(
    identity_ptr: *const u8,
    identity_len: usize,
) -> *mut MlsEngineHandle {
    let Some(identity) = as_slice(identity_ptr, identity_len) else {
        return ptr::null_mut();
    };
    match MlsEngine::new(identity) {
        Ok(engine) => Box::into_raw(Box::new(MlsEngineHandle { engine })),
        Err(_) => ptr::null_mut(),
    }
}

/// 释放引擎句柄。
///
/// # Safety
/// `handle` 须为 [`n42_mls_engine_new`] 返回且未被释放过的指针（或空）。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_engine_free(handle: *mut MlsEngineHandle) {
    if !handle.is_null() {
        drop(Box::from_raw(handle));
    }
}

/// 释放 [`N42Buf`]。
///
/// # Safety
/// `buf` 须为本库返回且未释放过的缓冲。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_buf_free(buf: N42Buf) {
    if !buf.ptr.is_null() && buf.len > 0 {
        drop(Vec::from_raw_parts(buf.ptr, buf.len, buf.len));
    }
}

macro_rules! handle_mut {
    ($h:expr) => {
        match $h.as_mut() {
            Some(h) => h,
            None => return N42_ERR_NULL,
        }
    };
}

/// 生成本端 KeyPackage → `out`。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_generate_key_package(
    handle: *mut MlsEngineHandle,
    out: *mut N42Buf,
) -> i32 {
    if out.is_null() {
        return N42_ERR_NULL;
    }
    *out = N42Buf::empty();
    let h = handle_mut!(handle);
    match h.engine.generate_key_package() {
        Ok(bytes) => {
            *out = N42Buf::from_vec(bytes);
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 新建群。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_create_group(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
) -> i32 {
    let h = handle_mut!(handle);
    let Some(gid) = as_str(gid_ptr, gid_len) else {
        return N42_ERR_UTF8;
    };
    match h.engine.create_group(gid) {
        Ok(()) => N42_OK,
        Err(_) => N42_ERR_MLS,
    }
}

/// 加单个成员（单 KeyPackage）。产出 commit→`out_commit`，welcome→`out_welcome`。
///
/// 多成员一次入群可多次调用或后续扩展为长度前缀数组；当前 ABI 单成员，简洁可靠。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_add_member(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
    kp_ptr: *const u8,
    kp_len: usize,
    out_commit: *mut N42Buf,
    out_welcome: *mut N42Buf,
) -> i32 {
    if out_commit.is_null() || out_welcome.is_null() {
        return N42_ERR_NULL;
    }
    *out_commit = N42Buf::empty();
    *out_welcome = N42Buf::empty();
    let h = handle_mut!(handle);
    let (Some(gid), Some(kp)) = (as_str(gid_ptr, gid_len), as_slice(kp_ptr, kp_len)) else {
        return N42_ERR_UTF8;
    };
    match h.engine.add_members(gid, &[kp.to_vec()]) {
        Ok((commit, welcome)) => {
            *out_commit = N42Buf::from_vec(commit);
            *out_welcome = N42Buf::from_vec(welcome);
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 移除成员（按叶子索引）。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_remove_member(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
    leaf_index: u32,
    out_commit: *mut N42Buf,
) -> i32 {
    if out_commit.is_null() {
        return N42_ERR_NULL;
    }
    *out_commit = N42Buf::empty();
    let h = handle_mut!(handle);
    let Some(gid) = as_str(gid_ptr, gid_len) else {
        return N42_ERR_UTF8;
    };
    match h.engine.remove_members(gid, &[leaf_index]) {
        Ok(commit) => {
            *out_commit = N42Buf::from_vec(commit);
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 应用收到的 commit。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_process_commit(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
    commit_ptr: *const u8,
    commit_len: usize,
) -> i32 {
    let h = handle_mut!(handle);
    let (Some(gid), Some(commit)) =
        (as_str(gid_ptr, gid_len), as_slice(commit_ptr, commit_len))
    else {
        return N42_ERR_UTF8;
    };
    match h.engine.process_commit(gid, commit) {
        Ok(()) => N42_OK,
        Err(_) => N42_ERR_MLS,
    }
}

/// 处理 welcome 加入群，群 id → `out_gid`（UTF-8）。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_process_welcome(
    handle: *mut MlsEngineHandle,
    welcome_ptr: *const u8,
    welcome_len: usize,
    out_gid: *mut N42Buf,
) -> i32 {
    if out_gid.is_null() {
        return N42_ERR_NULL;
    }
    *out_gid = N42Buf::empty();
    let h = handle_mut!(handle);
    let Some(welcome) = as_slice(welcome_ptr, welcome_len) else {
        return N42_ERR_NULL;
    };
    match h.engine.process_welcome(welcome) {
        Ok(gid) => {
            *out_gid = N42Buf::from_vec(gid.into_bytes());
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 群内加密 → `out`。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_encrypt(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
    pt_ptr: *const u8,
    pt_len: usize,
    out: *mut N42Buf,
) -> i32 {
    if out.is_null() {
        return N42_ERR_NULL;
    }
    *out = N42Buf::empty();
    let h = handle_mut!(handle);
    let (Some(gid), Some(pt)) = (as_str(gid_ptr, gid_len), as_slice(pt_ptr, pt_len)) else {
        return N42_ERR_UTF8;
    };
    match h.engine.encrypt(gid, pt) {
        Ok(ct) => {
            *out = N42Buf::from_vec(ct);
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 群内解密 → `out`。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_decrypt(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
    ct_ptr: *const u8,
    ct_len: usize,
    out: *mut N42Buf,
) -> i32 {
    if out.is_null() {
        return N42_ERR_NULL;
    }
    *out = N42Buf::empty();
    let h = handle_mut!(handle);
    let (Some(gid), Some(ct)) = (as_str(gid_ptr, gid_len), as_slice(ct_ptr, ct_len)) else {
        return N42_ERR_UTF8;
    };
    match h.engine.decrypt(gid, ct) {
        Ok(pt) => {
            *out = N42Buf::from_vec(pt);
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 自更新（PCS）→ commit `out`。
///
/// # Safety
/// 指针参数须满足模块说明的 (ptr, len) 有效性约定，`handle` 为有效引擎句柄。
#[no_mangle]
pub unsafe extern "C" fn n42_mls_self_update(
    handle: *mut MlsEngineHandle,
    gid_ptr: *const u8,
    gid_len: usize,
    out_commit: *mut N42Buf,
) -> i32 {
    if out_commit.is_null() {
        return N42_ERR_NULL;
    }
    *out_commit = N42Buf::empty();
    let h = handle_mut!(handle);
    let Some(gid) = as_str(gid_ptr, gid_len) else {
        return N42_ERR_UTF8;
    };
    match h.engine.self_update(gid) {
        Ok(commit) => {
            *out_commit = N42Buf::from_vec(commit);
            N42_OK
        }
        Err(_) => N42_ERR_MLS,
    }
}

/// 库版本字符串（C，静态，勿释放）。
#[no_mangle]
pub extern "C" fn n42_mls_version() -> *const c_char {
    concat!(env!("CARGO_PKG_VERSION"), "\0").as_ptr() as *const c_char
}

#[cfg(test)]
mod tests {
    use super::*;

    // 经 C ABI 跑通 alice 建群 + 加 bob + 双向收发，验证 ABI 与内存管理正确。
    #[test]
    fn ffi_round_trip() {
        unsafe {
            let alice = n42_mls_engine_new(b"alice".as_ptr(), 5);
            let bob = n42_mls_engine_new(b"bob".as_ptr(), 3);
            assert!(!alice.is_null() && !bob.is_null());

            // bob 的 key package
            let mut kp = N42Buf::empty();
            assert_eq!(n42_mls_generate_key_package(bob, &mut kp), N42_OK);
            assert!(kp.len > 0);

            // alice 建群 + 加 bob
            let gid = b"room";
            assert_eq!(
                n42_mls_create_group(alice, gid.as_ptr(), gid.len()),
                N42_OK
            );
            let mut commit = N42Buf::empty();
            let mut welcome = N42Buf::empty();
            assert_eq!(
                n42_mls_add_member(
                    alice,
                    gid.as_ptr(),
                    gid.len(),
                    kp.ptr,
                    kp.len,
                    &mut commit,
                    &mut welcome,
                ),
                N42_OK
            );
            assert!(welcome.len > 0);

            // bob 处理 welcome
            let mut out_gid = N42Buf::empty();
            assert_eq!(
                n42_mls_process_welcome(bob, welcome.ptr, welcome.len, &mut out_gid),
                N42_OK
            );
            let joined = slice::from_raw_parts(out_gid.ptr, out_gid.len);
            assert_eq!(joined, b"room");

            // alice 加密 → bob 解密
            let msg = b"ffi hello";
            let mut ct = N42Buf::empty();
            assert_eq!(
                n42_mls_encrypt(alice, gid.as_ptr(), gid.len(), msg.as_ptr(), msg.len(), &mut ct),
                N42_OK
            );
            let mut pt = N42Buf::empty();
            assert_eq!(
                n42_mls_decrypt(bob, gid.as_ptr(), gid.len(), ct.ptr, ct.len, &mut pt),
                N42_OK
            );
            assert_eq!(slice::from_raw_parts(pt.ptr, pt.len), msg);

            // 释放所有缓冲与句柄
            n42_mls_buf_free(kp);
            n42_mls_buf_free(commit);
            n42_mls_buf_free(welcome);
            n42_mls_buf_free(out_gid);
            n42_mls_buf_free(ct);
            n42_mls_buf_free(pt);
            n42_mls_engine_free(alice);
            n42_mls_engine_free(bob);
        }
    }

    #[test]
    fn ffi_null_handle_is_safe() {
        unsafe {
            let mut out = N42Buf::empty();
            assert_eq!(
                n42_mls_generate_key_package(ptr::null_mut(), &mut out),
                N42_ERR_NULL
            );
        }
    }
}
