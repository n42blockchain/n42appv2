#include "mobile_sdk.h"
#include "blst.h"

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *const validator_secret =
    "0x6be6c38a5986be6c7094e92017af0d15da0af6857362e2ba0c2103c3eb893eec";
static const char *const validator_public =
    "0x8a2470d8ccb2e43b3b5295cfee71508f8808e166e5f152d5af9fe022d95e300dc7c5814f2c9eb71e2da8412beb61c53a";

static void require(int condition, const char *message) {
  if (!condition) {
    fprintf(stderr, "FAIL: %s\n", message);
    exit(1);
  }
}

static void emit_success(const char *label, char *result, char **error_slot) {
  require(result != NULL && *error_slot == NULL, label);
  printf("CASE\t%s\t%s\n", label, result);
  rust_free_string(result);
}

static void require_error(const char *label, char *result, char **error_slot) {
  require(result == NULL &&
              (error_slot == NULL || *error_slot != NULL), label);
  if (error_slot != NULL) rust_free_string(*error_slot);
}

static int hex_value(char c) {
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  return -1;
}

static int decode_hex(const char *text, size_t chars, uint8_t *out) {
  for (size_t i = 0; i < chars / 2; i++) {
    const int high = hex_value(text[2 * i]);
    const int low = hex_value(text[2 * i + 1]);
    if (high < 0 || low < 0) return 0;
    out[i] = (uint8_t)((high << 4) | low);
  }
  return 1;
}

static void check_keypair(char *result, char **error_slot) {
  require(result != NULL && *error_slot == NULL, "keypair pointer contract");
  char secret_hex[65] = {0};
  char public_hex[97] = {0};
  int parsed = 0;
  require(sscanf(result, "[\"%64[0-9a-fA-F]\",\"%96[0-9a-fA-F]\"]%n",
                 secret_hex, public_hex, &parsed) == 2 &&
              parsed > 0 && result[parsed] == '\0' &&
              strlen(secret_hex) == 64 && strlen(public_hex) == 96,
          "keypair JSON/hex shape");
  uint8_t secret_bytes[32];
  uint8_t public_bytes[48];
  uint8_t derived_bytes[48];
  require(decode_hex(secret_hex, 64, secret_bytes) &&
              decode_hex(public_hex, 96, public_bytes),
          "keypair hex decode");
  blst_scalar scalar;
  blst_p1 derived;
  blst_scalar_from_bendian(&scalar, secret_bytes);
  require(blst_sk_check(&scalar), "BLS scalar validity");
  blst_sk_to_pk_in_g1(&derived, &scalar);
  blst_p1_compress(derived_bytes, &derived);
  require(memcmp(derived_bytes, public_bytes, 48) == 0,
          "independent C blst public-key relationship");
  memset(secret_bytes, 0, sizeof(secret_bytes));
  memset(secret_hex, 0, sizeof(secret_hex));
  rust_free_string(result);
  puts("CHECK\tkeypair_relation\tpass");
}

int main(void) {
  rust_free_string(NULL);
  char *error = NULL;
  check_keypair(generate_bls12_381_keypair_c(&error), &error);

  error = (char *)0x1;
  emit_success("deposit_prefixed",
               create_deposit_unsigned_tx_c(
                   "0x5FbDB2315678afecb367f032d93F642f64180aa3",
                   validator_secret,
                   "0xa0Ee7A142d267C1f36714E4a8F75612F20a79720",
                   "0x1bc16d674ec800000", &error),
               &error);
  error = NULL;
  emit_success("deposit_unprefixed",
               create_deposit_unsigned_tx_c(
                   "5FbDB2315678afecb367f032d93F642f64180aa3",
                   validator_secret + 2,
                   "a0Ee7A142d267C1f36714E4a8F75612F20a79720",
                   "1bc16d674ec800000", &error),
               &error);
  error = NULL;
  emit_success("fee_call", create_get_exit_fee_unsigned_tx_c(&error), &error);
  error = NULL;
  emit_success("exit_hex",
               create_exit_unsigned_tx_c(validator_public, "0x1", &error),
               &error);
  error = NULL;
  emit_success("exit_no_prefix",
               create_exit_unsigned_tx_c(validator_public + 2, "1", &error),
               &error);
  error = NULL;
  emit_success("exit_empty",
               create_exit_unsigned_tx_c(validator_public, "", &error), &error);
  error = NULL;
  emit_success("exit_null",
               create_exit_unsigned_tx_c(validator_public, NULL, &error), &error);

  error = NULL;
  require_error("invalid fee",
                create_exit_unsigned_tx_c(validator_public, "not-a-fee", &error),
                &error);
  require_error("invalid fee without error slot",
                create_exit_unsigned_tx_c(validator_public, "not-a-fee", NULL),
                NULL);
  error = NULL;
  require_error("invalid pubkey",
                create_exit_unsigned_tx_c("not-hex", "1", &error), &error);
  error = NULL;
  require_error("invalid wei",
                create_deposit_unsigned_tx_c(
                    "0x5FbDB2315678afecb367f032d93F642f64180aa3",
                    validator_secret,
                    "0xa0Ee7A142d267C1f36714E4a8F75612F20a79720",
                    "bad-wei", &error),
                &error);
  const char invalid_utf8[] = {(char)0xff, 0};
  error = NULL;
  require_error("invalid utf8",
                create_exit_unsigned_tx_c(invalid_utf8, "1", &error), &error);
  error = NULL;
  require_error("malformed block",
                gen_block_verify_result_c("not-json", "synthetic", &error),
                &error);
  error = NULL;
  require(run_client_c(NULL, "synthetic", &error) == -1 && error != NULL,
          "NULL run_client must reject before runtime/network");
  rust_free_string(error);
  puts("CHECK\terror_contract\tpass");
  return 0;
}
