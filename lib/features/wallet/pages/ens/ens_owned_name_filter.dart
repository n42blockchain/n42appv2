import 'package:n42_wallet/features/wallet/pages/ens/ens_chain_config.dart';
import 'package:n42_wallet/features/wallet/services/ens_models.dart';

List<OwnedEns> filterOwnedEnsByChain(
  Iterable<OwnedEns> ownedNames,
  EnsChainConfig chain,
) {
  return ownedNames
      .where(
        (ownedEns) =>
            EnsChainConfig.fromDomainName(ownedEns.name).id == chain.id,
      )
      .toList();
}
