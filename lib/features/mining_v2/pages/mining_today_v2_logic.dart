part of 'mining_today_v2.dart';

/// Business logic mixin for MiningTodayV2.
/// Handles data loading, wallet switching, unstaking dialog, and address selection.
mixin _MiningTodayV2LogicMixin on ConsumerState<MiningTodayV2> {
  final DataUtils dataUtils = DataUtils();
  StreamSubscription? _eventSubscription;

  Future<void> initData() async {
    var mv2 = ref.read(miningBridgeProvider);
    await mv2.loadMiningData();
  }

  Future<void> initDataWallet(EventPublicType pt) async {
    MiningV2Provider mp = ref.read(miningBridgeProvider);
    /*if (pt == EventPublicType.selectWallet) {
      // BUGFIX: Skip initialization only if depositsEnable has already been set
      // Previously was `!= null` which incorrectly skipped when already initialized
      if (mp.depositsEnable == null) return;
    }*/
    mp.resetData();
    await mp.checkAddressMiningStatus();
    await initData();
  }

  void unLockAstMining() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              S.current.g_mining_key20,
              style: TextStyle(color: AppColorTokens.of(context).textPrimary),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.g_key_79),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(S.current.g_key_78),
              onPressed: () async {
                try {
                  MiningV2Provider mp = ref.read(miningBridgeProvider);
                  if (mp.exitDepositLoad == Load.loading) return;
                  await mp.createExitDepositUnsignedTx();
                } catch (err) {
                  AppLogger.w('MiningTodayV2', 'err: $err');
                } finally {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showChangeAddress() {
    final miningProvider = ref.read(miningBridgeProvider);
    final walletList = miningProvider.miningWalletList;
    final currentIndex = miningProvider.currentMiningWalletIndex;

    sheetBottom(
      context,
      "",
      Column(
        children: [
          Container(
            height: ScreenUtil().setWidth(80),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).g_key_16,
              style: TextStyle(
                color: AppColorTokens.of(context).textPrimary,
                fontSize: ScreenUtil().setSp(36.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
            color: AppColorTokens.of(context).border,
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: ScreenUtil().setWidth(500.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30.0),
            ),
            child: ListView.builder(
              itemCount: walletList.length,
              itemBuilder: (context, int listIndex) {
                final wInfo = walletList[listIndex];
                final isSelected = wInfo.index == currentIndex;
                final walletColor = AppThemeUtils.getColorByKey(
                  context,
                  isSelected
                      ? AppThemeKeys.mainBlueColor.name
                      : AppThemeKeys.itemSubtitleTextColor.name,
                );
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (!isSelected) {
                          ref
                              .read(wapBridgeProvider)
                              .setWalletMiningIndex(wInfo.index);
                        }
                      },
                      child: Container(
                        height: ScreenUtil().setWidth(80.0),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                wInfo.isMainWallet
                                    ? S.of(context).g_key_14
                                    : S.of(context).g_key_6,
                                style: AppTypography.title.copyWith(color: walletColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(20.0)),
                            Flexible(
                              child: Text(
                                wInfo.name,
                                style: AppTypography.title.copyWith(color: walletColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      endIndent: 0,
                      indent: 0,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
