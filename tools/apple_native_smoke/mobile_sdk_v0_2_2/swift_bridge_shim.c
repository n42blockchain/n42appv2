#include "swift_bridge_shim.h"

#include <stdlib.h>
#include <string.h>

static int mode;
static int free_count;

void fake_set_mode(int next_mode) {
  mode = next_mode;
  free_count = 0;
}

int fake_free_count(void) { return free_count; }

void rust_free_string(char *value) {
  if (value != NULL) {
    ++free_count;
    free(value);
  }
}

static char *fake_result(char **out_error) {
  *out_error = mode == 1 || mode == 3 ? strdup("synthetic error") : NULL;
  return mode == 1 || mode == 2 ? strdup("{}") : NULL;
}

int32_t run_client_c(const char *url, const char *key, char **out_error) {
  (void)url;
  (void)key;
  *out_error = strdup("synthetic error");
  return 0;
}

char *gen_block_verify_result_c(const char *block, const char *key,
                                char **out_error) {
  (void)block;
  (void)key;
  return fake_result(out_error);
}

char *generate_bls12_381_keypair_c(char **out_error) {
  return fake_result(out_error);
}

char *create_deposit_unsigned_tx_c(const char *contract, const char *key,
                                   const char *withdrawal, const char *value,
                                   char **out_error) {
  (void)contract;
  (void)key;
  (void)withdrawal;
  (void)value;
  return fake_result(out_error);
}

char *create_get_exit_fee_unsigned_tx_c(char **out_error) {
  return fake_result(out_error);
}

char *create_exit_unsigned_tx_c(const char *key, const char *fee,
                                char **out_error) {
  (void)key;
  (void)fee;
  return fake_result(out_error);
}
