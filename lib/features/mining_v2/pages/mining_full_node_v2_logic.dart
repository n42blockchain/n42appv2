part of 'mining_full_node_v2.dart';

/// Business logic mixin for MiningFullNodeV2.
/// Handles balance checking, data initialization, and deposit handling.
mixin _MiningFullNodeV2LogicMixin on ConsumerState<MiningFullNodeV2> {
  final TokenViewApi _tokenViewApi = TokenViewApi();
  StreamSubscription? _eventSubscription;
  int _payType = 0;
  int _payMethod = 0;

  bool isLoadingAstBalance = false;
  bool isLoadingNftBalance = false;

  double? nBalance;
  //nft50num (拥有多少个50面额的NFT)
  BigInt nft50num = BigInt.zero;

  bool savePrivateKey = false;
  Map<String, dynamic>? encrypteData;

  Future<void> initData() async {
    await checkNBalance();
  }

  Future<void> checkNBalance() async {
    try {
      if (mounted) {
        setState(() {
          isLoadingAstBalance = true;
        });
      }

      final walletService = ref.read(walletServiceProvider);
      if (walletService == null) return;

      final miningIndex = walletService.miningWalletIndex;
      final coinInfo = walletService.getCoinInfoForWallet(miningIndex);
      if (coinInfo == null) return;

      final mnemonic =
          await walletService.getMnemonicForWallet(miningIndex);
      final privateKey =
          await walletService.getPrivateKeyForWallet(miningIndex);

      final astMap = coinInfo[CoinType.N.name];
      if (astMap == null) return;

      int pathIndex = astMap['pathIndex'] ?? 0;
      final path = getPathWithIndex(
          astMap["baseInfo"]["path"]["legacy"], pathIndex);

      Trustdart trustdart = Trustdart();
      var addressMap = await trustdart.generateAddress(
          CoinType.N.name, path, 'legacy',
          mnemonic: mnemonic ?? "", pk: privateKey ?? "");
      final astAddress = addressMap['legacy'];

      final bool isTest = astMap['isTest'] == true;
      final String rpc = isTest
          ? (astMap['baseInfo']['service_test'] ?? '')
          : (astMap['baseInfo']['service'] ?? '');
      MessageModel mm = await _tokenViewApi.getBalance(
            BlockchainType.Ethereum.name,
            CoinType.N.name,
            astAddress ?? '',
            isTest: isTest,
            rpc: rpc,
          ) ??
          MessageModel.error();
      if (mm.error) {
      } else {
        nBalance = toEther(mm.data.toString(), 18).toDouble();
        AppLogger.d('MiningFullNodeV2', 'ast mining token: $nBalance');
        if (mounted) {
          setState(() {});
        }
      }
    } catch (err) {
      AppLogger.w('MiningFullNodeV2', 'err: $err');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAstBalance = false;
        });
      }
    }
  }

  //开始质押
  Future<void> handlerData() async {
    if (encrypteData == null) {
      ToastUtils.show(S.of(context).g_mining_key_78);
      return;
    }
    try {
      MiningV2Provider mp = ref.read(miningBridgeProvider);
      mp.createDepositUnsignedTx(widget.nNum, encrypteData!);
    } catch (err) {
      //RPCError: got code 3 with msg "execution reverted: 10 N Deposit Limit has been reached".
      AppLogger.w('MiningFullNodeV2', 'stake failed: $err');
      if (err.toString().contains(S.of(context).g_mining_key_80)) {
        ToastUtils.show(S.of(context).g_mining_key_80);
      }
    }
  }
}
