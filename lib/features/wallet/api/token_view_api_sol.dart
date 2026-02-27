part of 'token_view_api.dart';

// ── Solana (SOL) ───────────────────────────────────────────────────────────

extension TokenViewApiSolana on TokenViewApi {
  /// 获取 Solana 余额（含 SPL 代币）
  Future<MessageModel> getBalanceSolana(
    String coinType,
    String address,
    String contract, {
    bool returnDouble = false,
    bool isTest = false,
  }) async {
    try {
      final netMode = isTest ? 'test' : 'main';
      dynamic a;
      if (contract.isEmpty) {
        final params = {'pubkey': address, 'net_mode': netMode};
        a = await BaseApi.requestEmptyH.post(
          '${url}v1/sol/balance',
          params: params,
          data: params,
          header: header,
        );
      } else {
        final pubKey = await Trustdart().getPubKeySOL(address, contract);
        final params = {'pubkey': pubKey, 'net_mode': netMode};
        a = await BaseApi.requestEmptyH.post(
          '${url}v1/sol/token/account/balance',
          params: params,
          data: params,
          header: header,
        );
      }
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (contract.isEmpty) {
          mm.error = false;
          mm.data = BigInt.from(a['data']);
        } else {
          if (a['data']['error']['code'] != 0) {
            mm.data = a['data']['error']['message'];
          } else {
            mm.error = false;
            mm.data = BigInt.parse(
              a['data']['result']['value']['amount']?.toString() ?? '0',
            );
          }
        }
      } else {
        if (contract.isNotEmpty && a['code'] == 500) {
          mm.error = false;
          mm.data = BigInt.zero;
        } else {
          mm.data = errorMessage(a['code']);
        }
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取当前用户某合约的全部账号
  Future<MessageModel> getTokenAccountsByOwnerSolana(
    String address,
    String contract, {
    bool isTest = false,
  }) async {
    try {
      final params = {
        'mint': contract,
        'net_mode': isTest ? 'test' : 'main',
        'pubkey': address,
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/sol/token/accounts/by/owner',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = a['data']['result']['value'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取指定地址的账户信息
  Future<MessageModel> getAccountInfoSolana(
    String address, {
    bool isTest = false,
  }) async {
    try {
      final params = {
        'net_mode': isTest ? 'test' : 'main',
        'pubkey': address,
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/sol/account/info',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data']['result']['value']['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取最新块 hash
  Future<MessageModel> getRecentBlockhashSolana({bool isTest = false}) async {
    try {
      final params = {'net_mode': isTest ? 'test' : 'main'};
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/sol/recent/block/hash',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data']['result']['value']['blockhash'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 广播交易（Solana）
  Future<MessageModel> sendTxSolana(String signHash, String netMode) async {
    try {
      final params = {'net_mode': netMode, 'tx_hash': signHash};
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/sol/tx/send',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = a['data']['result'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 Solana gasPrice（已废弃，建议使用 SolApi.getFeeForMessage）
  Future<MessageModel> getGasPriceSolana({bool isTest = false}) async {
    try {
      final params = {'net_mode': isTest ? 'test' : 'main'};
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/sol/fees',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = BigInt.from(
          a['data']['result']['value']['feeCalculator']['lamportsPerSignature'],
        );
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 根据交易 hash 返回交易状态
  Future<MessageModel> getTransactionSolana(
    String txHash,
    String netMode,
  ) async {
    try {
      final params = {'net_mode': netMode, 'tx_sign': txHash};
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/sol/transaction',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 0) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = a['data']['result']['meta']['status'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
