part of 'mining_v2_provider.dart';

mixin _MiningActionsMixin on _MiningStateMixin {

  /// Get all wallets that support N chain (for mining).
  List<MiningWalletInfo> get miningWalletList {
    try {
      final wap = globalWapAdapter;
      return [
        for (int i = 0; i < wap.walletInfoLsit.length; i++)
          if (wap.walletInfoLsit[i].coinInfo?[CoinType.N.name] != null)
            MiningWalletInfo(
              index: i,
              name: wap.walletInfoLsit[i].walletName ?? 'Account${i + 1}',
              address: wap.walletInfoLsit[i].coinInfo?[CoinType.N.name]?['address'] ?? '',
              isMainWallet: wap.walletInfoLsit[i].mainWallet,
              hasCoinN: true,
            ),
      ];
    } catch (e) {
      debugPrint('miningWalletList error: $e');
      return [];
    }
  }

  /// Current selected mining wallet index.
  int get currentMiningWalletIndex {
    try {
      WalletActionProvider wap = globalWapAdapter;
      return wap.walletMiningIndex;
    } catch (e) {
      return -1;
    }
  }

  /// Set mining wallet by index.
  Future<void> setMiningWalletByIndex(int index) async {
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet, intValue: index));
    notifyListeners();
  }

  /// Returns the WalletInfo at the current mining index, or null if invalid.
  WalletInfo? _getMiningWalletInfo() {
    final wap = globalWapAdapter;
    if (wap.walletInfoLsit.isEmpty) return null;
    final idx = wap.walletMiningIndex;
    if (idx < 0 || idx >= wap.walletInfoLsit.length) return null;
    return wap.walletInfoLsit[idx];
  }

  /// Check address mining status: staking N / NFT / group mining.
  @override
  Future<void> checkAddressMiningStatus() async {
    inactivityWarningShown = false; // 每次冷启动重置，允许重新检测
    try {
      final WalletInfo? wInfo = _getMiningWalletInfo();
      if (wInfo == null) return;
      Map<String, dynamic>? cInfo = wInfo.coinInfo?[CoinType.N.name];
      if (cInfo == null) return;

      Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
      var rm = await Trustdart().generateAddress(
        CoinType.N.name,
        getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
        cInfo['addrType'],
        mnemonic: wInfo.mnemonic ?? "",
        pk: wInfo.privateKey ?? "",
      );
      address = rm[cInfo['addrType']];
      await getWalletPrivateKey();

      walletName = wInfo.walletName ?? "";

      if (address == null) return;

      await getMiningData();
      if (depositsEnable == true) {
        connectWebSocket(
          wsUrl: AppConfig.miningWebSocketUrl,
          validatorPrivateKey: miningKeypart?['privateKey'] ?? "",
          validatorPubkey: miningKeypart?['publicKey'] ?? "",
        );
      }
      loadMiningData();

      await getWalletNBalance(address ?? "", cInfo);
    } catch (err) {
      setDepositsEnable(false);
      debugPrint("checkAddressMiningStatus err：${err.toString()}");
    } finally {
      notifyListeners();
    }
  }


  Future<void> getWalletPrivateKey() async {
    try {
      final WalletInfo? wInfo = _getMiningWalletInfo();
      if (wInfo == null) {
        errorMessage = "Wallet not available or mining index invalid!";
        notifyListeners();
        return;
      }

      final String? pk = wInfo.privateKey;

      if (pk == null || pk.isEmpty) {
        Map<String, dynamic>? nCoinInfo = wInfo.coinInfo?[CoinType.N.name];
        final mnemonic = wInfo.mnemonic;

        if (nCoinInfo != null && mnemonic != null && mnemonic.isNotEmpty) {
          Map<String, dynamic> pathMap = nCoinInfo['baseInfo']['path'];
          privateKey = await Trustdart().getPrivateKey(
            mnemonic,
            CoinType.N.name,
            getPathWithIndex(pathMap['legacy'], nCoinInfo['pathIndex']),
          );
        }
      } else {
        privateKey = pk;
      }

      if (privateKey == null) {
        errorMessage = "PrivateKey not found!";
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Error getting private key: $e";
      notifyListeners();
    }
  }


  Future<void> getNprice(WalletActionProvider wap) async {
    final coinInfo = wap.getCoinPriceWithUnit(CoinType.N.name);
    nPrice = coinInfo?['coinPrice'] ?? 0;
  }

  /// 获取钱包中 N 币余额
  Future<void> getWalletNBalance(String add, Map coinInfo) async {
    try {
      MessageModel rmm = await TokenViewApi().getBalance(
            BlockchainType.Ethereum.name,
            CoinType.N.name,
            add,
            isTest: coinInfo['isTest'],
            rpc: coinInfo['isTest']
                ? coinInfo['baseInfo']['service_test']
                : coinInfo['baseInfo']['service'],
          ) ??
          MessageModel.error();
      if (rmm.error == false) {
        walletNBalance = toEther(rmm.data.toString(), coinInfo['baseInfo']['decimals']).toDouble();
      }
      debugPrint('MiningV2Provider: N coin not found in wallet');
    } catch (e) {
      debugPrint('MiningV2Provider: Error getting wallet N balance: $e');
    }
  }


  void setDepositTxHash(String txHash) {
    depositTxHash = txHash;
    startCheckDepositTxHash(depositTxHash);
  }

  void setExitDepositTxHash(String txHash) {
    exitDepositTxHash = txHash;
    startCheckExitDepositTxHash(exitDepositTxHash);
  }

  @override
  Future<void> setMiningData(
    Map<String, dynamic> keypart,
    bool isMining, {
    bool redeem = false,
  }) async {
    miningData ??= {};
    miningData![address!] = {
      'isMining': isMining,
      'keypart': keypart,
      'redeem': redeem,
    };
    SPUtil().setMiningData(miningData!);
  }

  Future<void> getMiningData() async {
    miningData = await SPUtil().getMiningData();
    depositsEnable = miningData?[address!]?['isMining'] ?? false;
    miningKeypart = miningData?[address!]?['keypart'] ?? {};
    redeem = miningData?[address!]?['redeem'] ?? false;
  }

  /// Import mining data with wallet creation.
  ///
  /// TODO: This method still uses WalletActionProvider for wallet creation.
  /// Needs to be refactored to use IWalletService when wallet creation
  /// functionality is added to the service interface.
  Future<MessageModel> setMiningDataImport(
    Map<String, dynamic> value,
    String password,
  ) async {
    WalletActionProvider wap = globalWapAdapter;
    int index = wap.walletInfoLsit.indexWhere((test) {
      if (test.privateKey == value['privateKey']) return true;
      if (test.mnemonic == value['mnemonicWords']) return true;
      return false;
    });
    String importAddress = "";
    WalletInfo wInfo;

    if (index == -1) {
      if (value['mnemonicWords'] != "") {
        final checkMnemonic = await Trustdart().checkMnemonic(value['mnemonicWords']);
        if (checkMnemonic == false) {
          return MessageModel.error()..data = S.current.w_key_12;
        } else {
          wInfo = WalletInfo(mnemonic: value['mnemonicWords']);
        }
        wInfo.password = password;
      } else {
        wInfo = WalletInfo(privateKey: value['privateKey']);
        wInfo.password = '';
      }
      wInfo.walletName = "Account${wap.walletInfoLsit.length + 1}";
      wInfo.walletUuid = wap.userUUID;
      wInfo.coinInfo = chainUrlMap;
      wInfo.timestamp = "${DateTime.now().millisecondsSinceEpoch}";
    } else {
      wInfo = wap.walletInfoLsit[index];
    }

    Map<String, dynamic> cInfo = wInfo.coinInfo?[CoinType.N.name];
    Map<String, dynamic> pathMap = cInfo['baseInfo']['path'];
    var rmAddress = await Trustdart().generateAddress(
      CoinType.N.name,
      getPathWithIndex(pathMap[cInfo['addrType']], cInfo['pathIndex']),
      cInfo['addrType'],
      mnemonic: wInfo.mnemonic ?? "",
      pk: wInfo.privateKey ?? "",
    );
    importAddress = rmAddress[cInfo['addrType']];

    if (index == -1) {
      await wap.addWalletInfo(wInfo);
    }

    miningData ??= {};
    if (miningData?[importAddress] != null) {
      return MessageModel.error()..data = S.current.g_mining_key_83;
    }

    miningData![importAddress] = {
      'isMining': value['isMining'],
      'keypart': value['validator'],
      'redeem': false,
    };
    SPUtil().setMiningData(miningData!);
    wap.setWalletMiningIndex(
      index == -1 ? wap.walletInfoLsit.length - 1 : index,
    );
    return MessageModel();
  }

  /// Create deposit (staking) unsigned transaction.
  Future<void> createDepositUnsignedTx(
    int amount,
    Map<String, dynamic> encrypteData,
  ) async {
    try {
      depositLoad = Load.loading;
      notifyListeners();
      miningKeypart = encrypteData['validator'];
      String? rData = await mining.createDepositUnsignedTx(
        miningKeypart?['privateKey'] ?? "",
        address ?? "",
        DataUtils().bigIntToHex(ethToWeiString('$amount', 18)),
      );
      if (rData != null) {
        MessageModel sendMM = await web3.sendDepositTransaction(jsonDecode(rData));
        if (sendMM.error == false) {
          setDepositTxHash(sendMM.data);
          errorMessage = "";
        } else {
          errorMessage = sendMM.data;
          depositLoad = Load.finish;
        }
        notifyListeners();
      } else {
        errorMessage = "Error!";
        depositLoad = Load.finish;
      }
    } catch (e) {
      ToastUtils.show(e.toString());
      depositLoad = Load.finish;
      notifyListeners();
    }
  }

  @override
  void startCheckDepositTxHash(String txHash) {
    txCheckTimer?.cancel();
    txCheckTimer = Timer.periodic(
      const Duration(seconds: kTxConfirmCheckIntervalSeconds),
      (timer) async {
        if (await _checkTxHash(txHash) == false) {
          endCheckTxHash();
          depositLoad = Load.finish;
          notifyListeners();
          setMiningData(miningKeypart!, true);
          eventBus.fire(EventPublic(EventPublicType.miningFullNode));
          checkAddressMiningStatus();
        }
      },
    );
  }


  Future<void> createExitDepositUnsignedTx() async {
    exitDepositLoad = Load.loading;
    notifyListeners();

    String? feeWeiInHexTx = await _miningCreateGetExitFeeUnsignedTx();
    if (feeWeiInHexTx == null) {
      errorMessage = "'miningCreateGetExitFeeUnsignedTx' method error!";
      exitDepositLoad = Load.finish;
      notifyListeners();
      return;
    }

    MessageModel feeMM = await web3.exitDepositRowCall(feeWeiInHexTx);
    if (feeMM.error) {
      errorMessage = feeMM.data;
      exitDepositLoad = Load.finish;
      notifyListeners();
      return;
    }

    final exitSignDataStr = await _miningCreateExitUnsignedTx(feeMM.data);
    MessageModel sendMM = await web3.sendExitDepositTransaction(
      jsonDecode(exitSignDataStr ?? '{}'),
    );
    if (sendMM.error == false) {
      setExitDepositTxHash(sendMM.data);
      errorMessage = "";
    } else {
      errorMessage = sendMM.data;
      exitDepositLoad = Load.finish;
    }
    notifyListeners();
  }

  @override
  void startCheckExitDepositTxHash(String txHash) {
    txCheckTimer?.cancel();
    txCheckTimer = Timer.periodic(
      const Duration(seconds: kTxConfirmCheckIntervalSeconds),
      (timer) async {
        if (await _checkTxHash(txHash) == false) {
          exitDepositLoad = Load.finish;
          redeem = true;
          notifyListeners();
          endCheckTxHash();
          setMiningData(miningKeypart!, true, redeem: true);
          getBeaconValidator();
        }
      },
    );
  }


  @override
  void endCheckTxHash() {
    txCheckTimer?.cancel();
    txCheckTimer = null;
  }

  Future<bool> _checkTxHash(String txHash) async {
    MessageModel rmm = await web3.getTransactionReceipt(txHash);
    return rmm.error;
  }


  Future<void> runMining() async {
    final String? rData = await mining.runClient(
      miningKeypart?['privateKey'] ?? "",
    );
    if (rData == null) {
      errorMessage = 'Running the "runClient" method failed!';
    } else if (rData == "Client started") {
      miningStatus = true;
      errorMessage = "";
    } else {
      miningStatus = false;
      errorMessage = rData;
    }
    notifyListeners();
  }


  Future<String?> _miningCreateGetExitFeeUnsignedTx() async {
    return mining.miningCreateGetExitFeeUnsignedTx();
  }

  Future<String?> _miningCreateExitUnsignedTx(String feeWeiInHex) async {
    return mining.miningCreateExitUnsignedTx(
      feeWeiInHex,
      miningKeypart?['publicKey'] ?? "",
    );
  }
}
