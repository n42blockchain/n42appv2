import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:date_format/date_format.dart' as dformat;

class BtcTransactionRecodeModel {
  int trId = 0;
  String address = "";
  String to1 = "";
  int price = 0;
  int gas = 0;
  String txHash = "";
  int confirmations = 0;
  int state = 0;
  String txTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  String errorMessage = "";
  String coinMiniName = "";
  String contract = "";
  List<InputModel>? inputModels;
  List<OutputModel>? outputModels;
  Map<String, dynamic> coin = {}; // 币基本信息
  int isTest = 0; // 是否是测试地址，0不是，1是
  String testnetUri = ""; // 测试网地址api地址
  String userUuid = AppGlobals.userInfo?.uuid ?? ""; // 用户uuid
  int walletIndex = 0; // 钱包id
  bool max = false; // 转账最大值

  String signStr = ""; // 不写入数据库
  int gasPrice = 0; // gas费
  String addrType = "segwit";
  List<String>? inputsAddress;
  List<String>? outputsAddress;
  String? inputAddressStr;
  String? outputAddressStr;

  List<InputModel> get inputModelsList {
    inputModels ??= [];
    return inputModels!;
  }

  List<OutputModel> get outputModelsList {
    outputModels ??= [];
    return outputModels!;
  }

  List<String> get inputsAddressList {
    if (inputsAddress == null) {
      inputsAddress = [];
      for (final im in inputModelsList) {
        inputsAddress!.addAll(im.address);
      }
    }
    return inputsAddress!;
  }

  List<String> get outputsAddressList {
    if (outputsAddress == null) {
      outputsAddress = [];
      for (final om in outputModelsList) {
        outputsAddress!.addAll(om.address);
      }
    }
    return outputsAddress!;
  }

  String get inputAddressStrValue {
    inputAddressStr ??= _buildAddressStr(inputsAddressList);
    return inputAddressStr!;
  }

  String get outputAddressStrValue {
    outputAddressStr ??= _buildAddressStr(outputsAddressList);
    return outputAddressStr!;
  }

  /// 构建地址展示字符串，过滤自身地址，格式化后逗号连接
  String _buildAddressStr(List<String> addrs) {
    final parts = addrs
        .where((addr) => address.toUpperCase() != addr.toUpperCase())
        .map((addr) => DataUtils().addressFarmat(addr))
        .toList();
    return parts.join(',');
  }

  String? txTimeStr;

  List<Map<String, dynamic>> inputModelsMap() {
    return inputModelsList.map((im) => im.toMap()).toList();
  }

  // 获取转出 utxo btc 总和
  int inputPrice() {
    return inputModelsList.fold(0, (sum, im) => sum + im.value);
  }

  // 获取 double 类型的转出 utxo btc 总和
  double inputPriceDouble() {
    return inputModelsList.fold(0.0, (sum, im) => sum + im.value / 100000000);
  }

  // 获取 double 类型的 price 转出金额
  double priceDouble() {
    if (price == 0) return 0;
    return toEther(price.toString(), coin['decimals']).toDouble();
  }

  // 获取 double 类型的 gas
  double gasDouble() {
    if (gas == 0) return 0;
    return toEther(gas.toString(), coin['decimals']).toDouble();
  }

  // 赋值 gas
  void setGasDouble(double g) {
    gas = BigInt.from(g * 100000000).toInt();
  }

  String getTxTimeStr() {
    if (txTimeStr == null) {
      final tt = txTime.length == 13 ? int.parse(txTime) : int.parse(txTime) * 1000;
      txTimeStr = dformat.formatDate(
        DateTime.fromMillisecondsSinceEpoch(tt),
        [dformat.yyyy, '/', dformat.mm, '/', dformat.dd, ' ', dformat.am, ' ', dformat.hh, ':', dformat.nn],
      );
    }
    return txTimeStr!;
  }

  BtcTransactionRecodeModel();

  BtcTransactionRecodeModel.fromMap(Map<String, dynamic> map) {
    final inputs = jsonDecode(map["input"]) as List<dynamic>;
    final outputs = jsonDecode(map["output"]) as List<dynamic>;
    for (final s in inputs) {
      inputModelsList.add(InputModel.fromMap(jsonDecode(s as String)));
    }
    for (final s in outputs) {
      outputModelsList.add(OutputModel.fromMap(jsonDecode(s as String)));
    }
    trId = map['trId'];
    address = map['address'];
    to1 = map['to1'];
    price = int.parse(map['price']);
    gas = int.parse(map['gas']);
    txHash = map['txHash'];
    confirmations = map['confirmations'];
    state = map['state'];
    txTime = map['txTime'];
    errorMessage = map['errorMessage'];
    coinMiniName = map['coinMiniName'];
    contract = map['contract'];
    coin = json.decode(map['coin']);
    isTest = map['isTest'];
    testnetUri = map['testnetUri'];
    userUuid = map['userUuid'];
    walletIndex = map['walletIndex'];
    gasPrice = map['gasPrice'];
  }

  Map<String, dynamic> toMapDb() {
    return {
      "address": address,
      "to1": to1,
      "price": price,
      "gas": gas,
      "txHash": txHash,
      "confirmations": confirmations,
      "state": state,
      "txTime": txTime,
      "coinMiniName": coinMiniName,
      "errorMessage": errorMessage,
      "contract": contract,
      "input": _encodeModels(inputModelsList.map((im) => im.toMap()).toList()),
      "output": _encodeModels(outputModelsList.map((om) => om.toMap()).toList()),
      "coin": json.encode(coin),
      'isTest': isTest,
      'testnetUri': testnetUri,
      'userUuid': userUuid,
      'walletIndex': walletIndex,
      'gasPrice': gasPrice,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "trId": trId,
      ...toMapDb(),
    };
  }

  static String _encodeModels(List<Map<String, dynamic>> models) {
    return jsonEncode(models.map((m) => jsonEncode(m)).toList());
  }
}

class InputModel {
  int value = 0;
  String txid = "";
  int vout = 0;
  String script = "";
  String witnessValue = "";
  int lockTime = 0;
  List<String> address = [];

  double valueDouble() {
    if (value == 0) return 0;
    return value / 100000000;
  }

  InputModel({
    this.value = 0,
    this.txid = "",
    this.vout = 0,
    this.script = "",
    this.witnessValue = "",
    this.lockTime = 0,
  });

  InputModel.fromMap(Map<String, dynamic> map) {
    value = int.parse(map['value']);
    txid = map['txid'];
    vout = map['vout'];
    script = map['script'];
    witnessValue = map['witnessValue'];
    lockTime = map['lockTime'];
    address = (map['address'] as List<dynamic>).map((a) => a.toString()).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      "value": value.toString(),
      "txid": txid,
      "vout": vout,
      "script": script,
      "witnessValue": witnessValue,
      "address": address,
      "lockTime": lockTime,
    };
  }
}

class OutputModel {
  List<String> address = [];
  int price = 0;
  String script = "";

  double priceDoubleValue() {
    if (price == 0) return 0;
    return price / 100000000;
  }

  OutputModel({this.price = 0, this.script = ""});

  OutputModel.fromMap(Map<String, dynamic> map) {
    address = (map['address'] as List<dynamic>).map((a) => a.toString()).toList();
    price = map['price'];
    script = map['script'];
  }

  Map<String, dynamic> toMap() {
    return {
      "address": address,
      "price": price,
      "script": script,
    };
  }
}
