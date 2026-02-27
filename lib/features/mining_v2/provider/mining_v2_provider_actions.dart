part of 'mining_v2_provider.dart';

// ============================================================================
// Mining Actions
//
// Wallet operations, deposit/exit transactions, tx-hash polling, and
// mining-data persistence.
// ============================================================================

mixin _MiningActionsMixin on _MiningStateMixin {
  // ==================== Wallet List Management ====================

  /// Get all wallets that support N chain (for mining).
  List<MiningWalletInfo> get miningWalletList {
    try {
      WalletActionProvider wap = globalWapAdapter;
      List<MiningWalletInfo> result = [];

      for (int i = 0; i < wap.walletInfoLsit.length; i++) {
        WalletInfo wInfo = wap.walletInfoLsit[i];
        if (wInfo.coinInfo?[CoinType.N.name] != null) {
          result.add(MiningWalletInfo(
            index: i,
            name: wInfo.walletName ?? 'Account${i + 1}',
            address: wInfo.coinInfo?[CoinType.N.name]?['address'] ?? '',
            isMainWallet: wInfo.mainWallet,
            hasCoinN: true,
          ));
        }
      }
      return result;
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

  // ==================== Address Mining Status ====================

  /// 抱团挖矿/质押NFT/质押N
  /// 新增：FUJI NFT 质押
  @override
  Future<void> checkAddressMiningStatus() async {
    inactivityWarningShown = false; // 每次冷启动重置，允许重新检测
    try {
      WalletActionProvider wap = globalWapAdapter;
      if (wap.walletInfoLsit.isEmpty) return;

      final miningIndex = wap.walletMiningIndex;
      if (miningIndex < 0 || miningIndex >= wap.walletInfoLsit.length) return;

      WalletInfo wInfo = wap.walletInfoLsit[miningIndex];
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

      // 获取钱包中 N 币余额
      await getWalletNBalance(address ?? "", cInfo);
    } catch (err) {
      setDepositsEnable(false);
      debugPrint("checkAddressMiningStatus err：${err.toString()}");
    } finally {
      notifyListeners();
    }
  }

  // ==================== Private Key ====================

  Future<void> getWalletPrivateKey() async {
    try {
      WalletActionProvider wap = globalWapAdapter;
      if (wap.walletInfoLsit.isEmpty) {
        errorMessage = "Wallet not available!";
        notifyListeners();
        return;
      }

      final miningIndex = wap.walletMiningIndex;
      if (miningIndex < 0 || miningIndex >= wap.walletInfoLsit.length) {
        errorMessage = "Mining wallet index invalid!";
        notifyListeners();
        return;
      }

      WalletInfo wInfo = wap.walletInfoLsit[miningIndex];
      String? pk = wInfo.privateKey;

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

  // ==================== N Coin Balance ====================

  Future<void> getNprice(WalletActionProvider wap) async {
    Map<String, dynamic>? coinInfo = wap.getCoinPriceWithUnit(CoinType.N.name);
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

  // ==================== Mining Data Persistence ====================

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

    // 导入钱包
    if (index == -1) {
      if (value['mnemonicWords'] != "") {
        bool checkMnemonic = await Trustdart().checkMnemonic(value['mnemonicWords']);
        if (checkMnemonic == false) {
          // 助记词输入错误
          MessageModel rmm = MessageModel.error();
          rmm.data = S.current.w_key_12;
          return rmm;
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
    if (miningData?[importAddress] == null) {
      miningData![importAddress] = {
        'isMining': value['isMining'],
        'keypart': value['validator'],
        'redeem': false,
      };
      SPUtil().setMiningData(miningData!);
      if (index == -1) {
        wap.setWalletMiningIndex(wap.walletInfoLsit.length - 1);
      } else {
        wap.setWalletMiningIndex(index);
      }
      MessageModel rmm = MessageModel();
      return rmm;
    } else {
      MessageModel rmm = MessageModel.error();
      // "验证者已经存在"
      rmm.data = S.current.g_mining_key_83;
      return rmm;
    }
  }

  // ==================== Deposit (Staking) ====================

  /// 质押
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

  // ==================== Exit Deposit (Un-staking) ====================

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

  // ==================== Tx Hash Utilities ====================

  @override
  void endCheckTxHash() {
    if (txCheckTimer != null) {
      txCheckTimer!.cancel();
      txCheckTimer = null;
    }
  }

  Future<bool> _checkTxHash(String txHash) async {
    MessageModel rmm = await web3.getTransactionReceipt(txHash);
    return rmm.error;
  }

  // ==================== Run Mining Client ====================

  Future<void> runMining() async {
    String? rData = await mining.runClient(
      miningKeypart?['privateKey'] ?? "",
    );
    if (rData != null) {
      if (rData == "Client started") {
        miningStatus = true;
        errorMessage = "";
      } else {
        miningStatus = false;
        errorMessage = rData;
      }
    } else {
      errorMessage = 'Running the "runClient" method failed!';
    }
    notifyListeners();
  }

  // ==================== API Helpers ====================

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
