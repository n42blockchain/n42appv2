import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/http/request_url.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/wallet/utils/chain/chain_eip1559.dart';
import 'package:web3dart/web3dart.dart';

class EthAPI{
  String? cType;
  String? rpc;
  String? api;
  EthAPI();
  EthAPI.init(this.cType,this.rpc,this.api);
  //获取余额
  Future<MessageModel> getBalance(String address,String contract,{bool isTest=false,String? coinType})async{
    if(contract==""){
      final result=await baseRPCEth("eth_getBalance",[address,"latest"],coinType:coinType??cType,isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }else{
      String addr=strip0x(address);
      final result=await baseRPCEth("eth_call",[{"from": address,
        "to": contract, "data": "0x70a08231000000000000000000000000$addr"
      },"latest"],coinType: coinType??cType,isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      return mm;
    }
  }
  //获取gasPrice
  Future<MessageModel> getGasPrice({bool isTest=false,String? coinType,})async{
    final result=await baseRPCEth("eth_gasPrice",[],coinType: coinType??cType,isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  //获取预估值
  Future<MessageModel> getGasLimit(
      String from,
      String to,
      BigInt gasPrice,
      BigInt value,
      BigInt gas,
      {String? coinType,String contract="",String data="",bool isTest=false,bool addLatest=true}
      )async{
    if(contract==""){
      /*List param=[];
      param.add({"from": from,
        "to": to,
        "gas":"0x${gas.toRadixString(16)}",
        "gasPrice":'0x${gasPrice.toRadixString(16)}',
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}'
        //"id":currentId++,
      });
      if(addLatest){
        param.add("latest");
      }*/

      Map<String,dynamic> params={
        "from": from,
        "to": to,
        //"gas_price":'0x${gasPrice.toRadixString(16)}',
        //"gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}',
        //"price":"0x${value.toRadixString(16)}",
        "value":"0x${value.toRadixString(16)}",
        //"coin":coinType??cType??"",
        //"net_mode":isTest?"test":"main",
        //"id":AppGlobals.nextId,
      };
      //params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      if(get1559WithChainSymbol(coinType??cType??"")){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      if(data !=""){
        params['data']=data;
      }
      //TokenViewApi tokenViewApi=TokenViewApi();
      //return await tokenViewApi.getGasEstimate_eth(params);
      final result=await baseRPCEth(
          "eth_estimateGas",
          [params,"latest"],
          coinType: coinType??cType,
          isTest: isTest);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      // On error, mm.data is already the message string from AppError.message
      return mm;
    }
    else{
      String toAddress=strip0x(to);
      String aaa=bytesToHex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=padUint8ListTo32(unsignedIntToBytes(value));
      String valueHex=bytesToHex(valueList);
      /*List param=[];
      param.add({"from": from,
        "to": contract,
        "gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        "data": "0x${aaa}000000000000000000000000$toAddress$valueHex",
        //"maxPriorityFee":"0x0",
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}'
      });
      if(addLatest){
        param.add("latest");
      }*/
      Map<String,dynamic> params={"from": from,
        "to": contract,
        //"gas_price":'0x${gasPrice.toRadixString(16)}',
        //"gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        //"maxFeePerGas":'0x${gasPrice.toRadixString(16)}',
        "data": "0x${aaa}000000000000000000000000$toAddress$valueHex",
        //"coin":coinType??cType??"",
        //"net_mode":isTest?"test":"main",
        "id":AppGlobals.nextId,
      };
      if(get1559WithChainSymbol(coinType??cType??"")){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      //TokenViewApi tokenViewApi=TokenViewApi();
      //return await tokenViewApi.getGasEstimate_eth(params);
      final result=await baseRPCEth("eth_estimateGas",[params,"latest"],isTest: isTest,coinType: coinType??cType);
      final mm=resultToMessageModel(result);
      if(mm.error==false){
        mm.data=hexToInt(mm.data);
      }
      // On error, mm.data is already the message string from AppError.message
      return mm;
    }
  }
  Future<MessageModel> getGasLimitByMap(Map<String,dynamic> map,{String? coinType,bool isTest=false,bool addLatest=true})async{
    List param=[map];
    if(addLatest){
      param.add("latest");
    }
    final result=await baseRPCEth("eth_estimateGas",param,coinType: coinType??cType,isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }
  //获取交易收据
  Future<MessageModel> getTransactionReceipt(String txHash,{String? coinType,bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCEth("eth_getTransactionReceipt",[txHash],coinType: coinType??cType,isTest: isTest),
    );
  }
  //获取交易信息
  Future<MessageModel> getTransactionByHash(String txHash, {String? coinType,bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCEth("eth_getTransactionByHash",[txHash],coinType: coinType??cType,isTest: isTest),
    );
  }
  //获取nonce值
  Future<MessageModel> getTransactionCount(String address,{String? coinType,bool isTest=false})async{
    final result=await baseRPCEth("eth_getTransactionCount",[address,"latest"],coinType: coinType??cType,isTest: isTest);
    final mm=resultToMessageModel(result);
    if(mm.error==false){
      mm.data=hexToInt(mm.data);
    }
    return mm;
  }

  //发送交易，返回交易hash（明确禁用重试，防止双发）
  Future<MessageModel> sendTransaction(String value,{String? coinType,bool isTest=false})async{
    return resultToMessageModel(
      await baseRPCEth("eth_sendRawTransaction",[value],coinType: coinType??cType,isTest: isTest,enableRetry: false),
    );
  }

  /// Raw eth_call with pre-built data
  /// Used for AA operations like getNonce from EntryPoint
  Future<MessageModel> ethCallRaw(String to, String data, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth(
        "eth_call",
        [{"to": to, "data": data}, "latest"],
        coinType: coinType ?? cType,
        isTest: isTest,
      ),
    );
  }

  /// Get contract code at address
  /// Used to check if a smart account is deployed
  Future<MessageModel> getCode(String address, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth(
        "eth_getCode",
        [address, "latest"],
        coinType: coinType ?? cType,
        isTest: isTest,
      ),
    );
  }

  Future<Result<dynamic, AppError>> baseRPCEth(
    String method,
    var value, {
    String? coinType,
    bool? isTest,
    bool enableRetry = true,
  }) async {
    try {
      final String url;
      if(coinType==null){
        final rpcUrl = rpc;
        if (rpcUrl == null || rpcUrl.isEmpty) {
          return Result.failure(AppError.blockchain(
            'ETH RPC URL is not configured',
            code: 'ETH_NO_RPC_URL',
          ));
        }
        url = rpcUrl;
      }else{
        url=RequestUrl().getUrl2(coinType, "rpc",isTest: isTest);
      }
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.nextId};
      final data=await BaseApi.requestEmptyH.post(url, params: {},data: postData,enableRetry: enableRetry);
      if(data.containsKey('error')){
        final errorObj = data['error'];
        final errorMsg = errorObj is Map
            ? (errorObj['message']?.toString() ?? errorObj.toString())
            : errorObj?.toString() ?? 'RPC error';
        return Result.failure(AppError.blockchain(
          errorMsg,
          code: 'ETH_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream;
      // any error reaching here is already user-readable or a logic fault.
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }
  // ──────────────────────────────────────────────────────────────
  // ERC-20 合约元数据读取（name / symbol / decimals）
  // 仅支持 EVM 兼容链，通过原始 eth_call 实现，无需完整 ABI 文件。
  // ──────────────────────────────────────────────────────────────

  /// 从 EVM 合约地址读取 ERC-20 Token 元信息。
  ///
  /// 成功时返回 `{name, symbol, decimals}`，失败（非合约地址/RPC 超时）返回 null。
  static Future<({String name, String symbol, int decimals})?> getErc20TokenInfo(
    String contractAddress,
    String rpcUrl,
  ) async {
    try {
      final ethAPI = EthAPI.init(null, rpcUrl, null);
      final addr = contractAddress.toLowerCase();

      // 并行调用 name() / symbol() / decimals() 三个 view 函数
      // 函数选择器：keccak256 前 4 字节
      //   name()     → 0x06fdde03
      //   symbol()   → 0x95d89b41
      //   decimals() → 0x313ce567
      final results = await Future.wait([
        ethAPI.baseRPCEth('eth_call', [{'to': addr, 'data': '0x06fdde03'}, 'latest']),
        ethAPI.baseRPCEth('eth_call', [{'to': addr, 'data': '0x95d89b41'}, 'latest']),
        ethAPI.baseRPCEth('eth_call', [{'to': addr, 'data': '0x313ce567'}, 'latest']),
      ]);

      if (results.any((r) => r.isFailure)) return null;

      final nameHex     = results[0].valueOrNull?.toString() ?? '';
      final symbolHex   = results[1].valueOrNull?.toString() ?? '';
      final decimalsHex = results[2].valueOrNull?.toString() ?? '';

      final name    = _abiDecodeString(nameHex);
      final symbol  = _abiDecodeString(symbolHex);
      final decimals = _abiDecodeUint8(decimalsHex);

      // 至少 symbol 非空才认为是合法的 ERC-20 合约
      if (symbol.isEmpty && name.isEmpty) return null;

      return (name: name, symbol: symbol, decimals: decimals);
    } catch (_) {
      return null;
    }
  }

  /// ABI 解码 `string` 返回值（动态类型）。
  ///
  /// 格式：[32B offset][32B length][data bytes]（均为 hex，去掉 0x 前缀后操作）
  static String _abiDecodeString(String hex) {
    try {
      final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
      // 至少需要 offset(64) + length(64) + 至少1字节数据
      if (clean.length < 128) return '';
      final lengthHex = clean.substring(64, 128);
      final length = int.parse(lengthHex, radix: 16);
      if (length == 0) return '';
      if (clean.length < 128 + length * 2) return '';
      final dataHex = clean.substring(128, 128 + length * 2);
      final bytes = Uint8List.fromList(
        List.generate(
          dataHex.length ~/ 2,
          (i) => int.parse(dataHex.substring(i * 2, i * 2 + 2), radix: 16),
        ),
      );
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return '';
    }
  }

  /// ABI 解码 `uint8` 返回值（定长 32 字节，取低 1 字节）。
  static int _abiDecodeUint8(String hex) {
    try {
      final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
      if (clean.isEmpty) return 18;
      // 取最后 2 个十六进制字符（即最低字节）
      return int.parse(clean.substring(clean.length > 2 ? clean.length - 2 : 0), radix: 16);
    } catch (_) {
      return 18; // ERC-20 默认 18 位小数
    }
  }

/*
  //获取abi文件
  static getABI(String coinType,String address,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();

      final data=await Api.requestEmptyH.get(Api.getUrl2(coinType, "api",isTest:isTest ), params: {
        "module":"contract",
        "action":"getabi",
        "address":address,
      },);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //获取abi文件
  static getTokenInfo(String coinType,String address,{bool isTest=false})async{
    try{
      MessageModel mm=MessageModel();

      final data=await Api.requestEmptyH.get(Api.getUrl2(coinType, "api",isTest:isTest ), params: {
        "module":"token",
        "action":"tokeninfo",
        "address":address,
      },);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
*/

  //获取 address 的交易列表
  Future<MessageModel> getTxList(String address,{String? coinType,String contractAddress="",bool isTest=false,int page=1,int offset=10})async{
    //?module=账户&action= txlist &address={地址哈希}
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> params;
      if(contractAddress==""){
        params={
          "address":address,
          "action":"txlist",
          "module":"account",
          "page":page,
          "offset":offset,
        };
      }else{
        params={
          "address":address,
          "action":"tokentx",
          "module":"account",
          "page":page,
          "offset":offset,
          "contractaddress":contractAddress,
        };
      }
      String url;
      if(coinType==null){
        url=api??"";
      }else{
        url=RequestUrl().getUrl2(coinType, "api",isTest: isTest);
      }
      var data=await BaseApi.requestEmptyH.get(url, params: params,);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
}
