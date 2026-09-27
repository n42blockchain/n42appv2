#include "mobile_sdk.h"

/* This file is linked for an iOS device and never executed. Volatile reads
 * force the linker to resolve each public C export from the selected archive. */
static void (*volatile exported_symbols[])(void) = {
    (void (*)(void))rust_free_string,
    (void (*)(void))run_client_c,
    (void (*)(void))gen_block_verify_result_c,
    (void (*)(void))generate_bls12_381_keypair_c,
    (void (*)(void))create_deposit_unsigned_tx_c,
    (void (*)(void))create_get_exit_fee_unsigned_tx_c,
    (void (*)(void))create_exit_unsigned_tx_c,
};

int main(void) {
  int count = 0;
  for (unsigned int index = 0; index < 7; index++) {
    count += exported_symbols[index] != 0;
  }
  return count == 7 ? 0 : 1;
}
