// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/atom_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_chain_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// Cosmos-SDK chain sender.
/// Handles ATOM, INJ, OSMO, TIA, DYDX, NTRN and all other Cosmos chains.
class CosmosSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();

  // Known Cosmos chain metadata: chainId + denom
  static const Map<String, _CosmosChainMeta> _knownChains = {
    'ATOM': _CosmosChainMeta('cosmoshub-4', 'uatom', 6),
    'INJ':  _CosmosChainMeta('injective-1', 'inj', 18),
    'OSMO': _CosmosChainMeta('osmosis-1', 'uosmo', 6),
    'TIA':  _CosmosChainMeta('celestia', 'utia', 6),
    'DYDX': _CosmosChainMeta('dydx-mainnet-1', 'adydx', 18),
    'NTRN': _CosmosChainMeta('neutron-1', 'untrn', 6),
    'AKT':  _CosmosChainMeta('akashnet-2', 'uakt', 6),
    'SCRT': _CosmosChainMeta('secret-4', 'uscrt', 6),
    'JUNO': _CosmosChainMeta('juno-1', 'ujuno', 6),
    'KUJI': _CosmosChainMeta('kaiyo-1', 'ukuji', 6),
    'STRD': _CosmosChainMeta('stride-1', 'ustrd', 6),
    'XPRT': _CosmosChainMeta('core-1', 'uxprt', 6),
    'RUNE': _CosmosChainMeta('thorchain-1', 'rune', 8),
    'KAVA2': _CosmosChainMeta('kava_2222-10', 'ukava', 6),
    'SEI2': _CosmosChainMeta('pacific-1', 'usei', 6),
    'CRE':  _CosmosChainMeta('crescent-1', 'ucre', 6),
    'SOMM': _CosmosChainMeta('sommelier-3', 'usomm', 6),
    'MARS': _CosmosChainMeta('mars-1', 'umars', 6),
    'CMDX': _CosmosChainMeta('comdex-1', 'ucmdx', 6),
    'BAND': _CosmosChainMeta('laozi-mainnet', 'uband', 6),
    'BLD':  _CosmosChainMeta('agoric-3', 'ubld', 6),
    'BLZ':  _CosmosChainMeta('bluzelle-9', 'ubnt', 6),
    'FET':  _CosmosChainMeta('fetchhub-4', 'afet', 18),
    'UMEE': _CosmosChainMeta('umee-1', 'uumee', 6),
    'AXL':  _CosmosChainMeta('axelar-dojo-1', 'uaxl', 6),
    'CANTO': _CosmosChainMeta('canto_7700-1', 'acanto', 18),
    'LUNA': _CosmosChainMeta('phoenix-1', 'uluna', 6),
    'LUNC': _CosmosChainMeta('columbus-5', 'uluna', 6),
    'NOBLE': _CosmosChainMeta('noble-1', 'uusdc', 6),
    'STARS': _CosmosChainMeta('stargaze-1', 'ustars', 6),
    'QSR':  _CosmosChainMeta('quasar-1', 'uqsr', 6),
    'COREUM': _CosmosChainMeta('coreum-mainnet-1', 'ucore', 6),
  };

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType.toUpperCase();
    final meta = _knownChains[coinType];
    final denomDecimals = meta?.decimals ?? params.decimals;

    // Get balance
    final mmb = await _tokenViewApi.getBalance(
      BlockchainType.Cosmos.name,
      CoinType.ATOM.name,
      params.fromAddress,
      isTest: false,
    ) ?? MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get gas price
    final mmg = await _tokenViewApi.getGasPrice(
      BlockchainType.Cosmos.name,
      CoinType.ATOM.name,
      isTest: false,
    ) ?? MessageModel.error();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;

    final gas = getCoinGas(CoinType.ATOM.name, contract: params.contractAddress.isNotEmpty);
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice = ethToWeiString(params.amount.toString(), denomDecimals);
    double adjustedAmount = params.amount;

    if (params.contractAddress.isEmpty) {
      if (valuePrice == chainBalance && params.sendMax) {
        if (totalGasPrice >= valuePrice) {
          return SendResult.fail(S.current.g_key_wallet_m5(coinType));
        }
        valuePrice = valuePrice - totalGasPrice;
        adjustedAmount = toEther(valuePrice.toString(), denomDecimals).toDouble();
      }
      if (valuePrice <= BigInt.zero || totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    } else {
      if (totalGasPrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    }

    // Get account info
    final serviceUrl = params.chainConfig?['baseInfo']?['service'] as String? ?? '';

    MessageModel amm;
    if (coinType == 'ATOM') {
      amm = await AtomApi().getAccounts(params.fromAddress);
    } else if (serviceUrl.isNotEmpty) {
      final api = CosmosChainApi(serviceUrl, meta?.denom ?? 'u${coinType.toLowerCase()}');
      amm = await api.getAccount(params.fromAddress);
    } else {
      amm = await AtomApi().getAccounts(params.fromAddress);
    }
    if (amm.error) return SendResult.fail(amm.data?.toString());

    final accountData = amm.data as Map<String, dynamic>;
    final accountNumber = accountData['account_number']?.toString() ?? '0';
    final sequence = accountData['sequence']?.toString() ?? '0';
    final denom = meta?.denom ?? 'u${coinType.toLowerCase()}';
    final chainId = meta?.chainId ?? 'cosmoshub-4';

    final signMap = <String, dynamic>{
      'chainId': chainId,
      'toAddress': params.toAddress,
      'accountNumber': accountNumber,
      'sequence': sequence,
      'memo': params.memo ?? 'memo',
      'fee': {
        'gas': totalGasPrice.toString(),
        'amount': '5000',
        'denom': denom,
      },
      'amount': {
        'amount': valuePrice.toString(),
        'denom': denom,
      },
    };

    // Sign using ATOM coin type for all Cosmos chains
    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.ATOM.name,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.ATOM.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: CoinType.ATOM.name,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(sigResult.errorMessage ?? 'Signature validation failed');
    }

    // Broadcast
    MessageModel sendMm;
    if (coinType == 'ATOM') {
      sendMm = await AtomApi().sendTxs(signStr);
    } else if (serviceUrl.isNotEmpty) {
      final api = CosmosChainApi(serviceUrl, denom);
      sendMm = await api.sendTx(signStr);
    } else {
      sendMm = await AtomApi().sendTxs(signStr);
    }

    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}

class _CosmosChainMeta {
  final String chainId;
  final String denom;
  final int decimals;
  const _CosmosChainMeta(this.chainId, this.denom, this.decimals);
}
