import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:date_format/date_format.dart' as dformat;

class TransationRecordModel {
  int trId = 0;
  String address = '';
  int coinId = 0;
  String from1 = '';
  String to1 = '';
  BigInt price = BigInt.from(0);
  BigInt gasPrice = BigInt.from(0); // 手续费
  String txHash = '';
  int state = 0;
  String txTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  String errorMessage = '';
  String coinMiniName = '';
  String contract = '';
  Map<String, dynamic> coin = {}; // 币基本信息
  int isTest = 0; // 是否是测试地址，0不是，1是
  String testnetUri = ''; // 测试网 API 地址
  String userUuid = AppGlobals.userInfo?.uuid ?? ''; // 用户 uuid
  int walletIndex = 0; // 钱包 id

  String? nonce;
  String? message;

  dynamic other; // 其它信息
  BigInt gasPriceValue = BigInt.zero; // 每个字节多少 gas 费
  int gas = 1;
  String addrType = 'legacy';
  String erc721Or1155 = '';
  bool returnSignHash = false;
  String? txTimeStr;

  // 获取 double 类型的 price（转出金额）
  double priceDouble() {
    if (price == BigInt.zero) return 0;
    return toEther(price.toString(), coin['decimals']).toDouble();
  }

  double gasPriceDouble() {
    if (gasPrice == BigInt.zero || coin.isEmpty) return 0;
    return toEther(gasPrice.toString(), coin['decimals']).toDouble();
  }

  TransationRecordModel();

  TransationRecordModel.fromMap(Map<String, dynamic> map) {
    trId = map['trId'];
    address = map['address'];
    coinId = map['coinId'];
    from1 = map['from1'].toLowerCase();
    to1 = map['to1'].toLowerCase();
    price = BigInt.parse(map['price']);
    txHash = map['txHash'];
    state = map['state'];
    txTime = map['txTime'];
    errorMessage = map['errorMessage'];
    coinMiniName = map['coinMiniName'];
    contract = map['contract'].toLowerCase();
    coin = json.decode(map['coin']);
    isTest = map['isTest'];
    testnetUri = map['testnetUri'];
    userUuid = map['userUuid'];
    walletIndex = map['walletIndex'];
    message = map['message'];
  }

  // 公共字段（toMapDb 与 toMap 共享）
  Map<String, dynamic> _baseMap() => {
        'address': address,
        'coinId': coinId,
        'from1': from1.toLowerCase(),
        'to1': to1.toLowerCase(),
        'state': state,
        'txHash': txHash,
        'price': price.toString(),
        'txTime': txTime,
        'errorMessage': errorMessage,
        'coinMiniName': coinMiniName,
        'contract': contract.toLowerCase(),
        'coin': json.encode(coin),
        'isTest': isTest,
        'testnetUri': testnetUri,
        'userUuid': userUuid,
        'walletIndex': walletIndex,
        'message': message,
      };

  // 转为数据库需要的 map（不含 trId，由数据库自动生成）
  Map<String, dynamic> toMapDb() => _baseMap();

  // 转为完整 map（含 trId）
  Map<String, dynamic> toMap() => {
        'trId': trId,
        ..._baseMap(),
      };

  String getTxTimeStr() {
    if (txTimeStr == null) {
      final raw = int.parse(txTime);
      final ms = txTime.length == 13 ? raw : raw * 1000;
      txTimeStr = dformat.formatDate(
        DateTime.fromMillisecondsSinceEpoch(ms),
        [
          dformat.yyyy, '/', dformat.mm, '/', dformat.dd,
          ' ', dformat.am, ' ', dformat.hh, ':', dformat.nn,
        ],
      );
    }
    return txTimeStr!;
  }
}

class AlgoTrModel {
  String type;
  AlgoTrModel(this.type);
}

class FilTrModel {
  String gasFeeCap;
  String gasPremium;
  FilTrModel(this.gasFeeCap, this.gasPremium);
}

class RippleTrModel {
  String txType;
  int sequence;
  int? destinationTag; // 转账到交易所时通常必填，防止资产丢失
  RippleTrModel(this.txType, this.sequence, {this.destinationTag});
}
