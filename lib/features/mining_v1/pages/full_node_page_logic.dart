part of 'full_node_page.dart';

/// Business logic (balance checks, staking, chain confirmation) for [FullNodePage].
mixin _FullNodePageLogic on State<FullNodePage> {
  _FullNodePageState get _self => this as _FullNodePageState;

  Future<void> checkAstBalance() async {
    try {
      setState(() {
        _self.isLoadingAstBalance = true;
      });
      WalletActionProvider wap = globalWapAdapter;
      MiningProvider mp = globalMiningV1;
      //获取ast的 private key
      WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];
      final Map<String, dynamic>? map = walletInfo.coinInfo;
      final astMap = map?[CoinType.N.name];
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path =
          getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      Trustdart trustdart = Trustdart();
      var addressMap = await trustdart.generateAddress(CoinType.N.name, path,
          'legacy',
          mnemonic: walletInfo.mnemonic ?? "", pk: walletInfo.privateKey ?? "");
      final astAddress = addressMap['legacy'];
      final isMainChainMining = await MiningUtils.isMainChainMining();
      TokenViewApi tokenViewApi = TokenViewApi();
      MessageModel? mm = await tokenViewApi.getBalance(
        BlockchainType.Ethereum.name,
        CoinType.N.name,
        astAddress ?? '',
        isTest: !isMainChainMining,
      );
      if (mm != null && !mm.error) {
        _self.astBalance = toEther(mm.data.toString(), 18).toDouble();
        debugPrint("ast mining token : ${_self.astBalance}");
        if (mounted) {
          setState(() {});
        }
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    } finally {
      setState(() {
        _self.isLoadingAstBalance = false;
      });
    }
  }

  /// Main confirm-button tap handler: routes to the correct payment flow.
  Future<void> _handleConfirmTap() async {
    if (_self.load == Load.loading) return;
    if (_self._payType != 0) return;

    if (_self._payMethod == 0) {
      await _handleDirectPayment();
    } else if (_self._payMethod == 2) {
      await _handleSwapPayment();
    }
  }

  /// Direct AST payment flow.
  Future<void> _handleDirectPayment() async {
    if (_self.astBalance == null || _self.astBalance! < 50) {
      await checkAstBalance();
    }
    if (_self.astBalance == null || _self.astBalance! < 50) return;
    if (_self.astBalance! < widget.astNum) return;

    //计算解锁时间
    int currTime = DateTime.now().millisecondsSinceEpoch;
    int yearTime = 365 * 24 * 60 * 60 * 1000;
    int totalTime = currTime + yearTime;
    String lockTime = _self.dataUtils
        .getTimeByTimeStamp("$totalTime", format: "dd/MM/yyyy");
    showGroupConfirmDialog(context, widget.astNum, lockTime, () async {
      await handlerData();
    });
  }

  /// USDT-to-AST swap payment flow.
  Future<void> _handleSwapPayment() async {
    WalletActionProvider wap = globalWapAdapter;
    MiningProvider mp = globalMiningV1;
    WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];
    if (walletInfo.password == "") {
      final flag = await tipsDialog7(context);
      if (flag != null && flag) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'BackupOne'),
            builder: (context) => BackupOne(walletInfo, mp.walletIndex),
          ),
        );
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SwapAstHome(
          getAstNum: widget.astNum.toDouble(),
        ),
      ));
    }
  }

  //开始质押
  Future<void> handlerData() async {
    try {
      ///设置质押数量
      WalletActionProvider wap = globalWapAdapter;
      MiningProvider mp = globalMiningV1;
      //获取ast的 private key
      WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];
      final Map<String, dynamic>? map = walletInfo.coinInfo;
      final astMap = map?[CoinType.N.name];
      if (astMap != null) {
        int pathIndex = astMap['pathIndex'] ?? 0;
        final path =
            getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
        String? privateKey = walletInfo.privateKey;
        if (walletInfo.privateKey == null) {
          privateKey = await Trustdart()
              .getPrivateKey(walletInfo.mnemonic!, CoinType.N.name, path);
        }
        final pk = base64Decode(privateKey!);

        //1、调用evmSdk sign
        BigInt an = ethToWeiString('${widget.astNum}', 18);
        final res = await MiningPluginUtils.blsSign(
          bytesToHex(pk, padToEvenLength: true),
          _self.dataUtils
              .bigIntToHex(an, need0x: false, padToEvenLength: true),
        );

        if (res == null || res["data"] == null) {
          return;
        }

        //2、调用质押合约
        //2.1 bls 公钥
        final blsMap = await MiningPluginUtils.getPubKey(
          bytesToHex(pk, padToEvenLength: true),
        );
        //2.2 质押rpc
        try {
          setState(() {
            _self.load = Load.loading;
          });
          final data = await MiningApi.deposit(
              blsMap?["data"], res["data"], BigInt.from(widget.astNum));
          if (data != null) {
            // 返回交易hash：tx:0x80e92d4a89dba6af4774408c73437ac6bce4d6c578f348017553462e11f0f958
            // success
            SPUtil().setMiningOpen(true);

            /// 根据交易hash 获取是否上链
            await waitChainData(data);
          }
        } catch (err) {
          //RPCError: got code 3 with msg "execution reverted: 10 AST Deposit Limit has been reached".
          debugPrint("质押失败：${err.toString()}");
          if (err.toString().contains('insufficient funds for transfer')) {
            ToastUtils.show("insufficient funds for transfer");
          }
        } finally {
          setState(() {
            _self.load = Load.finish;
          });
        }
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<bool> checkChainData(String txHash) async {
    final chainData = await MiningApi.getTransactionReceipt(txHash);
    return chainData != null;
  }

  Future<void> waitChainData(String txHash) async {
    try {
      await Future.delayed(const Duration(seconds: 2), () async {
        final chainData = await MiningApi.getTransactionReceipt(txHash);
        if (chainData != null) {
          globalMiningV1.setDepositsEnable(true);
          //开启挖矿
          debugPrint("----->>>>>>  EVM插件 开启挖矿 <<<<<<-----");
          MiningPluginUtils.start();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ShareMining(
                fromType: _self._payType == 0 ? 2 : 3,
                astValue: widget.astNum,
              ),
            ),
          );
          return;
        } else {
          await waitChainData(txHash);
        }
      });
    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }
}
