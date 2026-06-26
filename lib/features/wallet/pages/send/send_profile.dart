enum SendProfile { evm, utxo, xrp, memo }

SendProfile resolveSendProfile(String blockchainType) {
  const utxo = {'Bitcoin', 'Qtum', 'Decred'};
  const xrp = {'Ripple'};
  if (utxo.contains(blockchainType)) return SendProfile.utxo;
  if (xrp.contains(blockchainType)) return SendProfile.xrp;
  return switch (blockchainType) {
    'Solana' ||
    'Tron' ||
    'Algorand' ||
    'Filecoin' ||
    'Polkadot' ||
    'Sui' ||
    'TheOpenNetwork' ||
    'Zilliqa' ||
    'Cosmos' ||
    'Aptos' ||
    'Near' ||
    'Stellar' ||
    'Tezos' ||
    'VeChain' ||
    'Cardano' ||
    'MultiversX' ||
    'Starknet' ||
    'EOSIO' ||
    'Waves' ||
    'Neo' ||
    'Ontology' ||
    'NEM' ||
    'Nano' ||
    'ICON' ||
    'IOST' ||
    'Ark' ||
    'Hive' => SendProfile.memo,
    _ => SendProfile.evm,
  };
}
