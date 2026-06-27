/*
 * n42_mls.h — C ABI for the OpenMLS (RFC 9420) backend.
 *
 * Backs n42_chat's FfiMlsProtocol (MethodChannel "n42.chat/mls").
 * The Rust crate executes the real MLS cryptography (TreeKEM / HPKE / ratchet)
 * via OpenMLS; the native plugin (Android JNI / iOS) loads the compiled library
 * and translates MethodChannel calls into the functions below.
 *
 * Memory model:
 *   - Inputs are read-only (ptr, len) slices.
 *   - Outputs are returned via N42Buf out-params; the caller MUST release each
 *     returned buffer with n42_mls_buf_free().
 *   - Engine handles are released with n42_mls_engine_free().
 *   - Status: 0 = ok; negative = error (see N42_ERR_*).
 */
#ifndef N42_MLS_H
#define N42_MLS_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define N42_OK 0
#define N42_ERR_NULL (-1)
#define N42_ERR_UTF8 (-2)
#define N42_ERR_MLS (-3)

typedef struct MlsEngineHandle MlsEngineHandle;

/* Owned byte buffer returned to the caller; free with n42_mls_buf_free. */
typedef struct N42Buf {
  uint8_t *ptr;
  size_t len;
} N42Buf;

/* Lifecycle */
MlsEngineHandle *n42_mls_engine_new(const uint8_t *identity_ptr, size_t identity_len);
void n42_mls_engine_free(MlsEngineHandle *handle);
void n42_mls_buf_free(N42Buf buf);

/* Operations (return status code) */
int32_t n42_mls_generate_key_package(MlsEngineHandle *handle, N42Buf *out);
int32_t n42_mls_create_group(MlsEngineHandle *handle, const uint8_t *gid_ptr, size_t gid_len);
int32_t n42_mls_add_member(MlsEngineHandle *handle,
                           const uint8_t *gid_ptr, size_t gid_len,
                           const uint8_t *kp_ptr, size_t kp_len,
                           N42Buf *out_commit, N42Buf *out_welcome);
int32_t n42_mls_remove_member(MlsEngineHandle *handle,
                              const uint8_t *gid_ptr, size_t gid_len,
                              uint32_t leaf_index, N42Buf *out_commit);
int32_t n42_mls_process_commit(MlsEngineHandle *handle,
                               const uint8_t *gid_ptr, size_t gid_len,
                               const uint8_t *commit_ptr, size_t commit_len);
int32_t n42_mls_process_welcome(MlsEngineHandle *handle,
                                const uint8_t *welcome_ptr, size_t welcome_len,
                                N42Buf *out_gid);
int32_t n42_mls_encrypt(MlsEngineHandle *handle,
                        const uint8_t *gid_ptr, size_t gid_len,
                        const uint8_t *pt_ptr, size_t pt_len, N42Buf *out);
int32_t n42_mls_decrypt(MlsEngineHandle *handle,
                        const uint8_t *gid_ptr, size_t gid_len,
                        const uint8_t *ct_ptr, size_t ct_len, N42Buf *out);
int32_t n42_mls_self_update(MlsEngineHandle *handle,
                            const uint8_t *gid_ptr, size_t gid_len,
                            N42Buf *out_commit);

const char *n42_mls_version(void);

#ifdef __cplusplus
}
#endif

#endif /* N42_MLS_H */
