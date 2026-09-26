//! Android JNI shim for the n42_mls C ABI.

use std::ptr;
use std::slice;

use jni::errors::ThrowRuntimeExAndDefault;
use jni::objects::{JByteArray, JObject};
use jni::sys::{jbyteArray, jint, jlong};
use jni::{Env, EnvUnowned};

use crate::ffi;

fn handle_from_jlong(handle: jlong) -> *mut ffi::MlsEngineHandle {
    handle as *mut ffi::MlsEngineHandle
}

fn bytes_from_array(env: &mut Env<'_>, array: JByteArray<'_>) -> Option<Vec<u8>> {
    env.convert_byte_array(array).ok()
}

fn empty_buf() -> ffi::N42Buf {
    ffi::N42Buf {
        ptr: ptr::null_mut(),
        len: 0,
    }
}

unsafe fn take_buf(buf: ffi::N42Buf) -> Vec<u8> {
    let bytes = if buf.ptr.is_null() || buf.len == 0 {
        Vec::new()
    } else {
        slice::from_raw_parts(buf.ptr, buf.len).to_vec()
    };
    ffi::n42_mls_buf_free(buf);
    bytes
}

fn byte_array_from_vec(env: &mut Env<'_>, bytes: Vec<u8>) -> jbyteArray {
    env.byte_array_from_slice(&bytes)
        .map(|array| array.into_raw())
        .unwrap_or(ptr::null_mut())
}

fn null_byte_array() -> jbyteArray {
    ptr::null_mut()
}

fn pack_pair(commit: Vec<u8>, welcome: Vec<u8>) -> Vec<u8> {
    let commit_len = commit.len().min(u32::MAX as usize) as u32;
    let mut packed = Vec::with_capacity(4 + commit.len() + welcome.len());
    packed.extend_from_slice(&commit_len.to_be_bytes());
    packed.extend_from_slice(&commit);
    packed.extend_from_slice(&welcome);
    packed
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeCreateEngine(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    identity: JByteArray<'_>,
) -> jlong {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_create_engine_impl(env, _obj, identity))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_create_engine_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    identity: JByteArray<'_>,
) -> jlong {
    let Some(identity) = bytes_from_array(env, identity) else {
        return 0;
    };
    unsafe { ffi::n42_mls_engine_new(identity.as_ptr(), identity.len()) as jlong }
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeFreeEngine(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
) {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            native_free_engine_impl(env, _obj, handle);
            Ok(())
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_free_engine_impl(_env: &mut Env<'_>, _obj: JObject<'_>, handle: jlong) {
    unsafe { ffi::n42_mls_engine_free(handle_from_jlong(handle)) }
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeGenerateKeyPackage(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_generate_key_package_impl(env, _obj, handle))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_generate_key_package_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
) -> jbyteArray {
    let mut out = empty_buf();
    let status = unsafe { ffi::n42_mls_generate_key_package(handle_from_jlong(handle), &mut out) };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let bytes = unsafe { take_buf(out) };
    byte_array_from_vec(env, bytes)
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeCreateGroup(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
) -> jint {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_create_group_impl(env, _obj, handle, group_id))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_create_group_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
) -> jint {
    let Some(group_id) = bytes_from_array(env, group_id) else {
        return ffi::N42_ERR_NULL as jint;
    };
    unsafe {
        ffi::n42_mls_create_group(handle_from_jlong(handle), group_id.as_ptr(), group_id.len())
            as jint
    }
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeAddMember(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    key_package: JByteArray<'_>,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_add_member_impl(
                env,
                _obj,
                handle,
                group_id,
                key_package,
            ))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_add_member_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    key_package: JByteArray<'_>,
) -> jbyteArray {
    let (Some(group_id), Some(key_package)) = (
        bytes_from_array(env, group_id),
        bytes_from_array(env, key_package),
    ) else {
        return null_byte_array();
    };
    let mut commit = empty_buf();
    let mut welcome = empty_buf();
    let status = unsafe {
        ffi::n42_mls_add_member(
            handle_from_jlong(handle),
            group_id.as_ptr(),
            group_id.len(),
            key_package.as_ptr(),
            key_package.len(),
            &mut commit,
            &mut welcome,
        )
    };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let packed = unsafe { pack_pair(take_buf(commit), take_buf(welcome)) };
    byte_array_from_vec(env, packed)
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeRemoveMember(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    leaf_index: jint,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_remove_member_impl(
                env, _obj, handle, group_id, leaf_index,
            ))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_remove_member_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    leaf_index: jint,
) -> jbyteArray {
    let Some(group_id) = bytes_from_array(env, group_id) else {
        return null_byte_array();
    };
    if leaf_index < 0 {
        return null_byte_array();
    }
    let mut out = empty_buf();
    let status = unsafe {
        ffi::n42_mls_remove_member(
            handle_from_jlong(handle),
            group_id.as_ptr(),
            group_id.len(),
            leaf_index as u32,
            &mut out,
        )
    };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let bytes = unsafe { take_buf(out) };
    byte_array_from_vec(env, bytes)
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeProcessCommit(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    commit: JByteArray<'_>,
) -> jint {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_process_commit_impl(
                env, _obj, handle, group_id, commit,
            ))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_process_commit_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    commit: JByteArray<'_>,
) -> jint {
    let (Some(group_id), Some(commit)) = (
        bytes_from_array(env, group_id),
        bytes_from_array(env, commit),
    ) else {
        return ffi::N42_ERR_NULL as jint;
    };
    unsafe {
        ffi::n42_mls_process_commit(
            handle_from_jlong(handle),
            group_id.as_ptr(),
            group_id.len(),
            commit.as_ptr(),
            commit.len(),
        ) as jint
    }
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeProcessWelcome(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    welcome: JByteArray<'_>,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_process_welcome_impl(env, _obj, handle, welcome))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_process_welcome_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    welcome: JByteArray<'_>,
) -> jbyteArray {
    let Some(welcome) = bytes_from_array(env, welcome) else {
        return null_byte_array();
    };
    let mut out_gid = empty_buf();
    let status = unsafe {
        ffi::n42_mls_process_welcome(
            handle_from_jlong(handle),
            welcome.as_ptr(),
            welcome.len(),
            &mut out_gid,
        )
    };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let bytes = unsafe { take_buf(out_gid) };
    byte_array_from_vec(env, bytes)
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeEncrypt(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    plaintext: JByteArray<'_>,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_encrypt_impl(env, _obj, handle, group_id, plaintext))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_encrypt_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    plaintext: JByteArray<'_>,
) -> jbyteArray {
    let (Some(group_id), Some(plaintext)) = (
        bytes_from_array(env, group_id),
        bytes_from_array(env, plaintext),
    ) else {
        return null_byte_array();
    };
    let mut out = empty_buf();
    let status = unsafe {
        ffi::n42_mls_encrypt(
            handle_from_jlong(handle),
            group_id.as_ptr(),
            group_id.len(),
            plaintext.as_ptr(),
            plaintext.len(),
            &mut out,
        )
    };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let bytes = unsafe { take_buf(out) };
    byte_array_from_vec(env, bytes)
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeDecrypt(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    ciphertext: JByteArray<'_>,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_decrypt_impl(env, _obj, handle, group_id, ciphertext))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_decrypt_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
    ciphertext: JByteArray<'_>,
) -> jbyteArray {
    let (Some(group_id), Some(ciphertext)) = (
        bytes_from_array(env, group_id),
        bytes_from_array(env, ciphertext),
    ) else {
        return null_byte_array();
    };
    let mut out = empty_buf();
    let status = unsafe {
        ffi::n42_mls_decrypt(
            handle_from_jlong(handle),
            group_id.as_ptr(),
            group_id.len(),
            ciphertext.as_ptr(),
            ciphertext.len(),
            &mut out,
        )
    };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let bytes = unsafe { take_buf(out) };
    byte_array_from_vec(env, bytes)
}

#[no_mangle]
pub extern "system" fn Java_ai_n42_www_MlsNativeBridge_nativeSelfUpdate(
    mut unowned_env: EnvUnowned<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
) -> jbyteArray {
    unowned_env
        .with_env(|env| -> jni::errors::Result<_> {
            Ok(native_self_update_impl(env, _obj, handle, group_id))
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

fn native_self_update_impl(
    env: &mut Env<'_>,
    _obj: JObject<'_>,
    handle: jlong,
    group_id: JByteArray<'_>,
) -> jbyteArray {
    let Some(group_id) = bytes_from_array(env, group_id) else {
        return null_byte_array();
    };
    let mut out = empty_buf();
    let status = unsafe {
        ffi::n42_mls_self_update(
            handle_from_jlong(handle),
            group_id.as_ptr(),
            group_id.len(),
            &mut out,
        )
    };
    if status != ffi::N42_OK {
        return null_byte_array();
    }
    let bytes = unsafe { take_buf(out) };
    byte_array_from_vec(env, bytes)
}
