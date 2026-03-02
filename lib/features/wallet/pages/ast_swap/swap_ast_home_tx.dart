part of 'swap_ast_home.dart';

extension _SwapAstHomeGasAndTx on _SwapAstHomeState {
  Future<bool> getGasPrice() async {
    if (payCoinModel == null) {
      errorMessage = "Error";
      return false;
    }
    gas = BigInt.from(
        getCoinGas(payCoinModel!.coin['coinType'] as String, contract: true));

    final MessageModel mm = await _tokenViewApi.getGasPrice(
          payCoinModel!.coin['blockchainType'] as String,
          payCoinModel!.coin['coinType'] as String,
          isTest: false,
          rpc: payCoinModel!.custom
              ? payCoinModel!.coin['service'] as String?
              : null,
        ) ??
        MessageModel.error();

    if (mm.error) {
      errorMessage = mm.data.toString();
      return false;
    }
    gasPrice = mm.data as BigInt;
    if (get1559WithChainSymbol(payCoinModel!.coin['coinType'] as String)) {
      gasPrice = gasPrice * BigInt.from(2);
    }
    totalGasPrice = gasPrice * gas;
    return true;
  }

  Future<bool> estimateGasEth() async {
    if (payCoinModel == null) return true;
    if (payCoinModel!.balance == BigInt.zero) {
      if (!mounted) return false;
      errorMessage =
          S.of(context).g_key_t_29(payCoinModel!.coin['coinType'] as String);
      rebuild();
      return false;
    }
    final String blockchainType =
        payCoinModel!.coin['blockchainType'] as String;
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
        payCoinModel!.coin['coinType'] as String,
        contract: youPay!.payCoinContract!,
        isTest: false,
      );
      if (!mounted) return false;

      if (ethMessage.error) {
        errorMessage = ethMessage.data as String;
        rebuild(() => load = Load.finish);
        return false;
      }

      gas = ethMessage.data as BigInt;
      totalGasPrice = gasPrice * gas;
      if (payCoinModel!.balance < totalGasPrice) {
        errorMessage =
            S.of(context).g_key_t_29(payCoinModel!.coin['coinType'] as String);
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
    rebuild(() => load = Load.loading);

    final MessageModel rOrderData = await _swapAstApi.postNftOrAstAddOrder(
      getCoinModel!.address.toString(),
      AppGlobals.userInfo?.uuid ?? "",
      youPay!.id ?? 0,
      2,
      double.parse(getTextEditingController.text),
    );

    if (rOrderData.error) {
      errorMessage = rOrderData.data as String;
      rebuild(() => load = Load.finish);
      return false;
    }

    errorMessage = "";
    orderId = (rOrderData.data as Map<String, dynamic>)['id'] as int;
    final double amount =
        ((rOrderData.data as Map)['amount'] as num).toDouble();
    final double price =
        ((rOrderData.data as Map)['price'] as num).toDouble();
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
    errorMessage = rOrderData.error ? rOrderData.data as String : "";
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
      errorMessage = rData.data as String;
      return false;
    }
    errorMessage = "";
    return true;
  }

  Future<String?> web3Transaction() async {
    final TransferApi transferApi = TransferApi();
    final MessageModel rData = await transferApi.transfer(
      payCoinModel!.coin['coinType'] as String,
      youPay?.payAddr ?? "",
      double.parse(payTextEditingController.text),
      fromAddress: payCoinModel!.address,
      contractAddress: youPay?.payCoinContract ?? "",
      isTest: false,
    );
    if (rData.error) {
      errorMessage = rData.data as String;
      return null;
    }
    errorMessage = "";
    return (rData.data as Map<String, dynamic>)['txHash'] as String?;
  }
}
