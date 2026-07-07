part of 'full_node_page.dart';

/// Business logic (balance checks, staking, chain confirmation) for [FullNodePage].
mixin _FullNodePageLogic on State<FullNodePage> {
  _FullNodePageState get _self => this as _FullNodePageState;

  Future<void> checkAstBalance() async {
    try {
      setState(() {
        _self.isLoadingAstBalance = true;
      });
      final WalletActionProvider wap = globalWapAdapter;
      final MiningProvider mp = globalMiningV1;
      final WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];
      final astMap = walletInfo.coinInfo?[CoinType.N.name];
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path = getPathWithIndex(
        astMap["baseInfo"]["path"]["legacy"],
        pathIndex,
      );
      Trustdart trustdart = Trustdart();
      var addressMap = await trustdart.generateAddress(
        CoinType.N.name,
        path,
        'legacy',
        mnemonic: walletInfo.mnemonic ?? "",
        pk: walletInfo.privateKey ?? "",
      );
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
        AppLogger.d('FullNodePage', 'ast mining token: ${_self.astBalance}');
        if (mounted) {
          setState(() {});
        }
      }
    } catch (err) {
      AppLogger.w('FullNodePage', 'init err: $err');
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

  /// Direct N42 payment flow.
  Future<void> _handleDirectPayment() async {
    if (_self.astBalance == null || _self.astBalance! < 50) {
      await checkAstBalance();
    }
    if (!mounted) return;
    if (_self.astBalance == null || _self.astBalance! < 50) return;
    if (_self.astBalance! < widget.astNum) return;

    final int currTime = DateTime.now().millisecondsSinceEpoch;
    int yearTime = 365 * 24 * 60 * 60 * 1000;
    int totalTime = currTime + yearTime;
    String lockTime = _self.dataUtils.getTimeByTimeStamp(
      "$totalTime",
      format: "dd/MM/yyyy",
    );
    showGroupConfirmDialog(context, widget.astNum, lockTime, () async {
      await handlerData();
    });
  }

  /// USDT-to-N42 swap payment flow.
  Future<void> _handleSwapPayment() async {
    final WalletActionProvider wap = globalWapAdapter;
    final MiningProvider mp = globalMiningV1;
    final WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];
    if (walletInfo.password == "") {
      final flag = await tipsDialog7(context);
      if (!mounted) return;
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SwapAstHome(getAstNum: widget.astNum.toDouble()),
        ),
      );
    }
  }

  Future<void> handlerData() async {
    try {
      final WalletActionProvider wap = globalWapAdapter;
      final MiningProvider mp = globalMiningV1;
      final WalletInfo walletInfo = wap.walletInfoLsit[mp.walletIndex];
      final astMap = walletInfo.coinInfo?[CoinType.N.name];
      if (astMap != null) {
        int pathIndex = astMap['pathIndex'] ?? 0;
        final path = getPathWithIndex(
          astMap["baseInfo"]["path"]["legacy"],
          pathIndex,
        );
        String? privateKey = walletInfo.privateKey;
        if (walletInfo.privateKey == null) {
          privateKey = await Trustdart().getPrivateKey(
            walletInfo.mnemonic!,
            CoinType.N.name,
            path,
          );
        }
        final pk = base64Decode(privateKey!);

        final BigInt an = ethToWeiString('${widget.astNum}', 18);
        final res = await MiningPluginUtils.blsSign(
          bytesToHex(pk, padToEvenLength: true),
          _self.dataUtils.bigIntToHex(an, need0x: false, padToEvenLength: true),
        );

        if (res == null || res["data"] == null) {
          return;
        }

        final blsMap = await MiningPluginUtils.getPubKey(
          bytesToHex(pk, padToEvenLength: true),
        );
        if (!mounted) return;
        try {
          setState(() {
            _self.load = Load.loading;
          });
          final data = await MiningApi.deposit(
            blsMap?["data"],
            res["data"],
            BigInt.from(widget.astNum),
          );
          if (data != null) {
            SPUtil().setMiningOpen(true);

            /// 根据交易hash 获取是否上链
            await waitChainData(data);
          }
        } catch (err) {
          AppLogger.w('FullNodePage', 'deposit error: $err');
          if (err.toString().contains('insufficient funds for transfer')) {
            ToastUtils.show("insufficient funds for transfer");
          }
        } finally {
          if (mounted) {
            setState(() {
              _self.load = Load.finish;
            });
          }
        }
      }
    } catch (err) {
      AppLogger.w('FullNodePage', '$err');
    }
  }

  Future<bool> checkChainData(String txHash) async {
    final chainData = await MiningApi.getTransactionReceipt(txHash);
    return chainData != null;
  }

  Future<void> waitChainData(String txHash, {int retries = 30}) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final chainData = await MiningApi.getTransactionReceipt(txHash);
      if (!mounted) return;
      if (chainData != null) {
        globalMiningV1.setDepositsEnable(true);
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
      } else if (retries > 0) {
        await waitChainData(txHash, retries: retries - 1);
      }
    } catch (err) {
      AppLogger.w('FullNodePage', 'waitChainData err: $err');
    }
  }
}
