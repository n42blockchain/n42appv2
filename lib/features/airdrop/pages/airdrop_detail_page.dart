// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';
import 'package:n42_wallet/features/airdrop/provider/airdrop_provider.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:url_launcher/url_launcher.dart';

part 'airdrop_detail_page_logic.dart';
part 'airdrop_detail_page_actions.dart';
part 'airdrop_detail_page_widgets.dart';

/// 空投详情页面
class AirdropDetailPage extends StatefulWidget {
  final AirdropModel airdrop;
  final AirdropProvider provider;

  const AirdropDetailPage({
    super.key,
    required this.airdrop,
    required this.provider,
  });

  @override
  State<AirdropDetailPage> createState() => _AirdropDetailPageState();
}

class _AirdropDetailPageState extends State<AirdropDetailPage>
    with AirdropDetailLogicMixin, AirdropDetailActionsMixin, AirdropDetailWidgetsMixin {
  @override
  void initState() {
    super.initState();
    // 自动触发资格检测：active/upcoming 且 isEligible 未知时
    final airdrop = widget.airdrop;
    if (airdrop.isEligible == null &&
        (airdrop.status == AirdropStatus.active ||
            airdrop.status == AirdropStatus.upcoming)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.checkEligibility(airdrop.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final airdrop = currentAirdrop;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 顶部 App Bar
              SliverAppBar(
                expandedHeight: ScreenUtil().setWidth(200),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    airdrop.projectName,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          ),
                          AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          ).withValues(alpha: 180 / 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                        child: Image.network(
                          airdrop.projectLogo,
                          width: ScreenUtil().setWidth(80),
                          height: ScreenUtil().setWidth(80),
                          errorBuilder: (ctx, error, stack) => Container(
                            width: ScreenUtil().setWidth(80),
                            height: ScreenUtil().setWidth(80),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                            ),
                            child: const Icon(Icons.token, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 内容
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      buildValueCard(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      buildTimeInfo(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      buildDescription(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      buildRequirements(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      if (airdrop.socialLinks != null && airdrop.socialLinks!.isNotEmpty)
                        buildSocialLinks(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(30)),
                      buildActionButtons(context, airdrop),
                      SizedBox(height: ScreenUtil().setWidth(40)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
