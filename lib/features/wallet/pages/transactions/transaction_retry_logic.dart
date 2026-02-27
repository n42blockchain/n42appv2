part of 'transaction_retry.dart';

/// Business logic mixin for [_TransactionRetryState].
///
/// Handles transaction lookup, receipt polling, speed-up / cancel
/// submission, and database persistence.
mixin _TransactionRetryLogicMixin on ConsumerState<TransactionRetry> {
  EthAPI? _ethAPI;
  EthAPI get ethAPI {
    _ethAPI ??= EthAPI();
    return _ethAPI!;
  }

  AppDatabase? _db;
  AppDatabase get db {
    _db ??= AppDatabase();
    return _db!;
  }

  final TextEditingController searchEditingController = TextEditingController();

  Load load = Load.finish;
  String errorMessage = '';
  TransationRecordModel trm = TransationRecordModel();

  TokenViewApi? _tokenViewApiInstance;
  TokenViewApi get tokenViewApi {
    _tokenViewApiInstance ??= TokenViewApi();
    return _tokenViewApiInstance!;
  }

  late String _txHash;
  late String _explorerUrl;

  Map<String, dynamic>? transactionInfo;
  Map<String, dynamic>? transactionInfoReceipt;
  String resultStr = 'Pending';
  String value = '';
  String gasPrice = '';
  String gasLimit = '';
  String nonce = '';
  bool owner = true; // 是否是自己的交易信息
  BigInt _originalGasPriceValue = BigInt.zero;
  Timer? timer;

  Future<void> init() async {
    if (_txHash == '') {
      _txHash = searchEditingController.text;
    }
    if (_txHash == '') {
      owner = false;
      return;
    }
    setState(() {
      load = Load.loading;
    });
    final List<TransationRecordModel> trModelList =
        await db.selectTransationRecordTxHash(
            _txHash, widget.coinModel.address);
    if (!mounted) return;
    if (trModelList.isNotEmpty) {
      trm = trModelList[0];
    } else {
      final TransationRecordModel trModel = TransationRecordModel();
      trModel.address = widget.coinModel.address.toString();
      trModel.from1 = widget.coinModel.address.toString();
      trModel.addrType = widget.coinModel.addrType;
      trModel.coin = widget.coinModel.coin;
      trModel.coinMiniName = widget.coinModel.coin['coinType'];
      trModel.walletIndex = ref.read(wapBridgeProvider).walletIndex;
      trModel.contract = widget.coinModel.isTest
          ? widget.coinModel.coin['contract_test']
          : widget.coinModel.coin['contract'];
      trModel.isTest = widget.coinModel.isTest ? 1 : 0;
      trModel.gasPrice = BigInt.zero;
      trModel.gasPriceValue = BigInt.zero;
      trModel.coinId = widget.coinModel.isTest
          ? widget.coinModel.coin['chainId_test']
          : widget.coinModel.coin['chainId'];
      trm = trModel;
    }
    final bool r = await getTransactionByHash();
    if (r) {
      await getTransactionReceipt();
      setState(() {
        load = Load.finish;
      });
    } else {
      setState(() {
        load = Load.error;
      });
    }
  }

  Future<bool> getTransactionByHash() async {
    final MessageModel rData = await ethAPI.getTransactionByHash(
      _txHash,
      coinType: widget.coinModel.coin['coinType'],
    );
    if (rData.error == false) {
      if (rData.data == null) {
        errorMessage = 'Not found';
        owner = false;
        return false;
      }
      transactionInfo = rData.data;
      trm.gas = hexToInt(transactionInfo!['gas'] ?? '0x0').toInt();
      trm.gasPriceValue = hexToInt(transactionInfo!['gasPrice'] ?? '0x0');
      _originalGasPriceValue = trm.gasPriceValue; // 缓存原始值，防止重复乘法
      resultStr = 'Pending';
      gasPrice = '${toGWei(trm.gasPriceValue.toString())} GWei';
      gasLimit = '${trm.gas}';
      nonce =
          '${hexToInt(transactionInfo!['nonce'] ?? '0x0').toInt()}';

      if (trm.contract == '') {
        try {
          trm.message = utf8.decode(hexToBytes(transactionInfo!['input']));
        } catch (e) {
          trm.message = '';
        }
        trm.to1 = transactionInfo!['to'];
        trm.price = hexToInt(transactionInfo!['value'] ?? '0x0');
        value =
            '${toEther(trm.price.toString(), widget.coinModel.coin['decimals'])} ${widget.coinModel.coin['unit']}';
      } else {
        try {
          trm.message = '';
          final String input = transactionInfo!['input'];
          final String to = input.substring(10, 74).substring(24);
          trm.to1 = '0x$to';
          final String valueStr = input.substring(74, 138);
          trm.price = hexToInt(valueStr);
          value =
              '${toEther(trm.price.toString(), widget.coinModel.coin['decimals'])} ${widget.coinModel.coin['unit']}';
        } catch (_) {
          // 错误安全忽略
        }
      }
      if (trm.from1.toLowerCase() !=
          (transactionInfo?['from'] ?? '').toString().toLowerCase()) {
        owner = false;
      } else {
        owner = true;
      }
      return true;
    } else {
      errorMessage = rData.data.toString();
      owner = false;
      return false;
    }
  }

  Future<void> getTransactionReceipt() async {
    final MessageModel rData = await ethAPI.getTransactionReceipt(
      _txHash,
      coinType: widget.coinModel.coin['coinType'],
    );
    if (rData.error == false) {
      transactionInfoReceipt = rData.data;
      if (transactionInfoReceipt != null) {
        // receipt 非 null 表示交易已上链确认，停止轮询
        if (_isReceiptSuccess(transactionInfoReceipt!['status'])) {
          resultStr = 'Success';
        } else {
          // 0x0 = 链上 revert，或其他异常状态
          resultStr = 'Failed';
        }
        return;
      }
      // receipt 为 null 表示仍在 mempool，继续轮询
      errorMessage = '';
    } else {
      errorMessage = rData.data.toString();
    }
    timerInit();
  }

  void timerInit() {
    timer = Timer(const Duration(seconds: 3), () {
      getTransactionReceipt();
    });
  }

  Future<void> send(String toAddress, BigInt transferValue,
      {bool isCancel = false}) async {
    if (load == Load.loading) return;
    if (errorMessage != '') return;
    if (!mounted) return;
    setState(() {
      load = Load.loading;
    });
    try {
      // Step 1: 计算替换 gasPrice（修复 Bug 2 双重乘法 / Bug 7 testnet RPC）
      final bool isEip1559 = transactionInfo!['gasPrice'] == '0x0' ||
          _originalGasPriceValue == BigInt.zero;
      final String? customRpc = widget.coinModel.coin['custom'] == true
          ? (widget.coinModel.isTest
              ? widget.coinModel.coin['service_test']
              : widget.coinModel.coin['service'])
          : null;

      BigInt newGasPriceValue;
      if (isEip1559) {
        // EIP-1559：从 API 获取当前市场价格 ×1.5（修复 Bug 2 错误乘法）
        final mm = await tokenViewApi.getGasPrice(
              BlockchainType.Ethereum.name,
              trm.coinMiniName,
              rpc: customRpc,
            ) ??
            MessageModel.error();
        if (!mounted) return;
        if (mm.error) {
          setState(() {
            load = Load.finish;
          }); // 修复 Bug 3 loading 卡死
          ToastUtils.show(mm.data);
          return;
        }
        newGasPriceValue =
            (mm.data as BigInt) * BigInt.from(3) ~/ BigInt.from(2);
      } else {
        // Legacy：从原始缓存值 ×1.5（修复 Bug 5 就地翻倍 / Bug 2 错误系数）
        newGasPriceValue =
            _originalGasPriceValue * BigInt.from(3) ~/ BigInt.from(2);
      }

      if (isCancel) {
        // Step 2a: 取消路径 —— 构造最小 cancel tx（修复 Bug 4 gas 浪费 / Bug 6 合约污染）
        final cancelTrm = _buildCancelTrm(newGasPriceValue);
        final bool check = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    WalletBaseSend(cancelTrm, null, cancelTrm.coin['unit'])));
        if (!mounted) return;
        if (!check) {
          setState(() {
            load = Load.finish;
          });
          return;
        }
        final mm = await TransferApi().transferWallet(
          trModel: cancelTrm,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex,
        );
        if (!mounted) return;
        await _handleTransferResult(mm, cancelTrm);
      } else {
        // Step 2b: 加速路径 —— 相同 nonce/目标/金额，更高 gasPrice
        trm.gasPriceValue = newGasPriceValue;
        trm.price = transferValue;
        trm.to1 = toAddress;
        trm.nonce = transactionInfo!['nonce'];
        trm.gas = hexToInt(transactionInfo!['gas']).toInt();

        final BigInt gaslimit = BigInt.from(getCoinGas(
          widget.coinModel.coin['coinType'],
          contract: widget.coinModel.coin['isContract'],
        ));
        final MessageModel gasEst = await tokenViewApi.getGasEstimateEthV2(
          widget.coinModel.address,
          trm.to1,
          trm.gasPriceValue,
          trm.price,
          gaslimit,
          widget.coinModel.coin['coinType'],
          contract: widget.coinModel.isTest
              ? widget.coinModel.coin['contract_test']
              : widget.coinModel.coin['contract'],
          isTest: widget.coinModel.isTest,
        );
        if (!mounted) return;
        if (gasEst.error == false) {
          trm.gas = (gasEst.data as BigInt).toInt();
        } else {
          setState(() {
            load = Load.finish;
          }); // 修复 Bug 3 loading 卡死
          ToastUtils.show(gasEst.data);
          return;
        }
        trm.gasPrice = trm.gasPriceValue * BigInt.from(trm.gas);

        final bool check = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    WalletBaseSend(trm, null, trm.coin['unit'])));
        if (!mounted) return;
        if (!check) {
          setState(() {
            load = Load.finish;
          });
          return;
        }
        final mm = await TransferApi().transferWallet(
          trModel: trm,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex,
        );
        if (!mounted) return;
        await _handleTransferResult(mm, trm);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          load = Load.finish;
        });
        ToastUtils.show(e.toString());
      }
    }
  }

  /// 构造取消交易的独立 model（不污染 trm，修复 Bug 6 合约污染 / Bug 4 gas 浪费）
  TransationRecordModel _buildCancelTrm(BigInt gasPriceValue) {
    return TransationRecordModel()
      ..address = trm.address
      ..from1 = trm.from1
      ..to1 = widget.coinModel.address // 发给自己
      ..price = BigInt.zero // 0 ETH
      ..gas = 21000 // 普通转账最小 gas，不需要估算
      ..gasPriceValue = gasPriceValue
      ..gasPrice = gasPriceValue * BigInt.from(21000)
      ..nonce = transactionInfo!['nonce'] // 必须与原交易相同，RBF 核心
      ..contract = '' // 无合约，修复 Bug 6
      ..coin = trm.coin
      ..coinMiniName = trm.coinMiniName
      ..coinId = trm.coinId
      ..isTest = trm.isTest
      ..addrType = trm.addrType
      ..walletIndex = trm.walletIndex;
  }

  /// 统一广播后处理（消除重复代码，修复 Bug 3 error 路径 loading 卡死）
  Future<void> _handleTransferResult(
      MessageModel mm, TransationRecordModel model) async {
    if (mm.error) {
      setState(() {
        load = Load.finish;
      });
      ToastUtils.show(mm.data);
    } else {
      model.txHash = mm.data;
      if (model.trId == 0) {
        model.trId = await db.insertTransationRecord(model);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(model, 1);
      } else {
        await db.updateTransationRecord(model);
        if (!mounted) return;
        ref.read(tripBridgeProvider).selectUndoneTr();
      }
      ToastUtils.show(S.current.g_key_nft_41);
      setState(() {
        load = Load.finish;
      });
      Navigator.pop(context, true);
    }
  }

  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
