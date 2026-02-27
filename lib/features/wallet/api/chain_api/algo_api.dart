import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:dio/dio.dart';

class AlgoApi {
  String _uri(bool isTest) => RequestUrl().getUrl2(CoinType.ALGO.name, 'api', isTest: isTest);

  /// 获取余额（native 或 ASA）
  Future<MessageModel> getBalance(String address, {String assetId = '', bool isTest = false}) async {
    try {
      final uri = _uri(isTest);
      if (assetId != '') {
        MessageModel data = await BaseApi.requestEmptyH.get('${uri}v2/accounts/$address/assets/$assetId', params: {});
        Response rData = data.data;
        if (rData.statusCode == 200 || rData.statusCode == 201) {
          Map<String, dynamic> rDataMap = jsonDecode(rData.data);
          data.data = {
            'balance': BigInt.from(rDataMap['asset-holding']['amount']),
            'code': rData.statusCode,
          };
        } else if (rData.statusCode == 404) {
          data.data = {'balance': BigInt.zero, 'code': rData.statusCode};
        }
        return data;
      } else {
        final data = await BaseApi.requestEmptyH.get('${uri}v2/accounts/$address', params: {});
        final mm = MessageModel();
        mm.data = {
          'balance': BigInt.from(data['amount']),
          'minBalance': BigInt.from(data['min-balance']),
        };
        return mm;
      }
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  /// 获取签名用的链上参数
  Future<MessageModel> getTransactionsParams({bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get('${_uri(isTest)}v2/transactions/params', params: {});
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  /// 发送交易
  Future<MessageModel> sendTx(Uint8List txHash, {bool isTest = false}) async {
    try {
      final txData = Stream.fromIterable(txHash.map((i) => [i]));
      final data = await BaseApi.requestEmptyH.post(
        '${_uri(isTest)}v2/transactions',
        params: {},
        data: txData,
        header: {'Content-Type': 'application/x-binary'},
      );
      return MessageModel()..data = data['txId'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  /// 根据 txid 获取交易信息
  Future<MessageModel> getTransactionsInfo(String txId, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get('${_uri(isTest)}v2/transactions/pending/$txId', params: {});
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }
}
