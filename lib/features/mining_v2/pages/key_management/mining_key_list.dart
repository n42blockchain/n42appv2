import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_output_tip.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';

class MiningKeyList extends ConsumerStatefulWidget {
  const MiningKeyList({super.key});

  @override
  ConsumerState<MiningKeyList> createState() => _MiningKeyListState();
}

class _MiningKeyListState extends ConsumerState<MiningKeyList> {
  Map<String, dynamic>? miningData;
  List<dynamic> miningList = [];
  List<String> miningKeyList = [];
  @override
  void initState() {
    super.initState();
    getMiningData();
  }

  Future<void> getMiningData() async {
    miningData = await SPUtil().getMiningData();
    if (miningData != null) {
      miningList = miningData!.values.toList();
      miningKeyList = miningData!.keys.toList();
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> removeKey(int index) async {
    miningData!.remove(miningKeyList[index]);
    await SPUtil().setMiningData(miningData!);
    getMiningData();
    if (!mounted) return;
    ref.read(miningBridgeProvider).getMiningData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_mining_key_81),
      body: ListView.builder(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        itemBuilder: (BuildContext context, index) {
          Map<String, dynamic> keyValue =
              miningList[index] as Map<String, dynamic>;
          bool isMining = keyValue['isMining'] ?? false;
          return containerStyle1(
            context,
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            miningKeyList[index],
                            style: AppTypography.headline.copyWith(
                              color: AppColorTokens.of(context).textItem,
                            ),
                          ),
                          Text(
                            isMining
                                ? S.of(context).g_key_193
                                : S.of(context).g_mining_key_102,
                            style: AppTypography.body.copyWith(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                isMining
                                    ? AppThemeKeys.rightTextColor.name
                                    : AppThemeKeys.errorTextColor.name,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!isMining)
                      InkWell(
                        onTap: () => removeKey(index),
                        child: Icon(
                          Icons.delete_forever_outlined,
                          color: AppColorTokens.of(context).danger,
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                    if (isMining)
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MiningOutputTip(value: keyValue['keypart']),
                          ),
                        ),
                        child: Icon(
                          Icons.output_outlined,
                          color: AppColorTokens.of(context).brand,
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                  ],
                ),
                Divider(
                  height: ScreenUtil().setWidth(20),
                  color: AppColorTokens.of(context).border,
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PublicKey:${keyValue['keypart']['publicKey']}',
                        style: AppTypography.headline.copyWith(
                          color: AppColorTokens.of(context).textItem,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: keyValue['keypart']['publicKey']),
                        );
                        ToastUtils.show(S.of(context).copy);
                      },
                      child: Icon(
                        Icons.copy,
                        color: AppColorTokens.of(context).brand,
                        size: ScreenUtil().setWidth(40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        itemCount: miningList.length,
      ),
    );
  }
}
