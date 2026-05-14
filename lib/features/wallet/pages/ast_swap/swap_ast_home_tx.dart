part of 'swap_ast_home.dart';

extension _SwapAstHomeGasAndTx on _SwapAstHomeState {
  Future<bool> getGasPrice() async {
    if (payCoinModel == null) {
      errorMessage = "Error";
      return false;
    }
    if (_payCoinType.isEmpty || _payBlockchainType.isEmpty) {
      errorMessage = "Invalid chain configuration";
      return false;
    }
    gas = BigInt.from(getCoinGas(_payCoinType, contract: true));

    final MessageModel mm = await _tokenViewApi.getGasPrice(
          _payBlockchainType,
          _payCoinType,
          isTest: false,
          rpc: payCoinModel!.custom ? _payServiceRpc : null,
        ) ??
        MessageModel.error();

    if (mm.error) {
      errorMessage = mm.data.toString();
      return false;
    }
    gasPrice = _swapBigIntValue(mm.data);
    if (get1559WithChainSymbol(_payCoinType)) {
      gasPrice = gasPrice * BigInt.from(2);
    }
    totalGasPrice = gasPrice * gas;
    return true;
  }

  Future<bool> estimateGasEth() async {
    if (payCoinModel == null) return true;
    if (payCoinModel!.balance == BigInt.zero) {
      if (!mounted) return false;
      errorMessage = S.of(context).g_key_t_29(_payCoinType);
      rebuild();
      return false;
    }
    final String blockchainType = _payBlockchainType;
    if (blockchainType != BlockchainType.Ethereum.name &&
        blockchainType != BlockchainType.Tron.name) {
      return true;
    }

    rebuild(() => load = Load.loading);

    final bool rGasPrice = await getGasPrice();
    if (!rGasPrice) {
      rebuild();
      return false;
    }

    try {
      final MessageModel ethMessage =
          await _tokenViewApi.getGasEstimateEthV2(
        payCoinModel!.address,
        youPay?.payCoinContract ?? "",
        gasPrice,
        ethToWeiString(
            payTextEditingController.text, youPay!.payCoinDecimal!),
        gas,
        _payCoinType,
        contract: youPay!.payCoinContract!,
        isTest: false,
      );
      if (!mounted) return false;

      if (ethMessage.error) {
        errorMessage = _swapStringValue(ethMessage.data, fallback: 'Error');
        rebuild(() => load = Load.finish);
        return false;
      }

      gas = _swapBigIntValue(ethMessage.data, fallback: gas);
      totalGasPrice = gasPrice * gas;
      if (payCoinModel!.balance < totalGasPrice) {
        errorMessage = S.of(context).g_key_t_29(_payCoinType);
        rebuild(() => load = Load.finish);
        return false;
      }
      errorMessage = "";
      rebuild(() => load = Load.finish);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      if (mounted) rebuild(() => load = Load.finish);
      return false;
    }
  }

  Future<bool> newOrder() async {
    if (load != Load.finish) return false;
    // Validate order amount before parsing
    final double? orderAmount = double.tryParse(getTextEditingController.text.trim());
    if (orderAmount == null || orderAmount <= 0 || orderAmount.isNaN || orderAmount.isInfinite) {
      errorMessage = "Invalid order amount";
      return false;
    }
    rebuild(() => load = Load.loading);

    final MessageModel rOrderData = await _swapAstApi.postNftOrAstAddOrder(
      getCoinModel!.address.toString(),
      AppGlobals.userInfo?.uuid ?? "",
      youPay!.id ?? 0,
      2,
      orderAmount,
    );

    if (rOrderData.error) {
      errorMessage = _swapStringValue(rOrderData.data, fallback: 'Error');
      rebuild(() => load = Load.finish);
      return false;
    }

    errorMessage = "";
    final orderData = _swapMapValue(rOrderData.data) ?? <String, dynamic>{};
    orderId = _swapIntValue(orderData['id']);
    final double amount = _swapDoubleValue(orderData['amount']);
    final double price = _swapDoubleValue(orderData['price']);
    getCoinModel!.coinPrice = price;
    payTextEditingController.text = amount.toString();
    payInput();
    rebuild(() => load = Load.finish);
    return true;
  }

  Future<void> cancelOrder() async {
    if (load != Load.finish) return;
    rebuild(() => load = Load.loading);

    final MessageModel rOrderData =
        await _swapAstApi.postNftOrAstCancelOrder(
      AppGlobals.userInfo?.uuid ?? "",
      orderId ?? 0,
    );
    errorMessage = rOrderData.error
        ? _swapStringValue(rOrderData.data, fallback: 'Error')
        : "";
    if (!rOrderData.error) orderId = null;
    rebuild(() => load = Load.finish);
  }

  Future<void> payTap() async {
    if (load != Load.finish) return;
    if (orderId == null) return;
    rebuild(() => load = Load.loading);

    final String? txHash = await web3Transaction();
    if (txHash != null) {
      final bool rData = await postOrderTxHash(orderId ?? 0, txHash);
      if (!mounted) return;
      if (rData) {
        await alertWidget(context);
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
    if (!mounted) return;
    rebuild(() => load = Load.finish);
  }

  Future<bool> postOrderTxHash(int oid, String txHash) async {
    final MessageModel rData = await _swapAstApi.postNftOrAstCommitPay(
        AppGlobals.userInfo?.uuid ?? "", oid, txHash);
    if (rData.error) {
      errorMessage = _swapStringValue(rData.data, fallback: 'Error');
      return false;
    }
    errorMessage = "";
    return true;
  }

  Future<String?> web3Transaction() async {
    if (_payCoinType.isEmpty || payCoinModel == null) {
      errorMessage = "Invalid chain configuration";
      return null;
    }
    // Validate pay amount before parsing
    final payText = payTextEditingController.text.trim();
    final double? payAmount = double.tryParse(payText);
    if (payAmount == null || payAmount <= 0 || payAmount.isNaN || payAmount.isInfinite) {
      errorMessage = "Invalid payment amount";
      return null;
    }
    final String payAddr = youPay?.payAddr ?? "";
    if (payAddr.isEmpty) {
      errorMessage = "Invalid recipient address";
      return null;
    }

    final cm = payCoinModel!;
    final addrType = cm.addrType;
    final baseInfo = cm.coin['baseInfo'] as Map<String, dynamic>?;
    final pathMap = baseInfo?['path'] as Map<String, dynamic>?;
    final basePath = pathMap?[addrType]?.toString() ?? "m/44'/60'/0'/0/0";
    final path = getPathWithIndex(basePath, cm.pathIndex);
    final decimals = (cm.coin['decimals'] as num?)?.toInt() ?? 18;
    final contractAddress = youPay?.payCoinContract ?? '';

    final result = await SenderFactory.instance.getSender(_payCoinType).send(
      SendParams(
        coinType: _payCoinType,
        fromAddress: cm.address.toString(),
        toAddress: payAddr,
        amount: payAmount,
        decimals: decimals,
        path: path,
        isTest: false,
        contractAddress: contractAddress,
        tokenDecimals: contractAddress.isNotEmpty ? decimals : 0,
        chainConfig: cm.coin,
      ),
    );

    if (!result.success) {
      errorMessage = _swapStringValue(result.error, fallback: 'Error');
      return null;
    }
    errorMessage = "";
    final txHash = result.txHash;
    return txHash != null && txHash.isNotEmpty ? txHash : null;
  }
}
