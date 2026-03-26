// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart' as f_picker;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/di/service_locator_setup.dart';
import 'package:n42_wallet/core/network/ipfs_api.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/home/models/appendix_model.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:video_compress/video_compress.dart';

class Feedback extends StatefulWidget {
  const Feedback({super.key});

  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  late final Regular regular = Regular();
  late final TextEditingController inputEditingController =
      TextEditingController();
  Load load = Load.finish;
  List<AppendixModel> appendixs = [];

  @override
  void dispose() {
    inputEditingController.dispose();
    super.dispose();
  }

  Future<void> getFile(int type) async {
    final result = await f_picker.FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: type == 0 ? f_picker.FileType.image : f_picker.FileType.video,
    );
    if (result == null) return;
    final fjCount = result.files.length.clamp(0, 5 - appendixs.length);

    for (int i = 0; i < fjCount; i++) {
      final pf = result.files[i];
      final am = AppendixModel()
        ..name = pf.name
        ..path = pf.path.toString()
        ..upTotal = pf.size;
      if (type == 1) {
        await createVideoImageMini(am);
      }
      appendixs.add(am);
      uploadFile(am);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> createVideoImageMini(AppendixModel am) async {
    am.imgMini = await VideoCompress.getByteThumbnail(
      am.path,
      quality: 25,
      position: -1,
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> uploadFile(AppendixModel am) async {
    try {
      am.cancelToken = CancelToken();
      if (!mounted) return;
      setState(() {
        am.state = 1;
        am.upCount = 0;
        am.upTotal = 0;
      });
      final rData = await IpfsApi().uploadIPFSImage(am.path, "fkImage.png", (
        int count,
        int total,
      ) {
        am.upCount = count;
        am.upTotal = total;
        if (!mounted) return;
        setState(() {});
      }, cancelToken: am.cancelToken);
      if (!mounted) return;
      setState(() {
        if (rData["error"]) {
          am.state = 3;
        } else {
          am.url = "${AppConfig.apiUrl['ipfsAddress']}${rData['data']['Hash']}";
          am.state = 2;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => am.state = 3);
    }
  }

  void deleteFile(AppendixModel am) {
    if (am.state == 1) am.cancelToken!.cancel();
    appendixs.remove(am);
    setState(() {});
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    final content = inputEditingController.text;
    if (content.isEmpty) {
      ToastUtils.show(S.of(context).g_key_feedback_1);
      return;
    }
    if (!appendixs.every((am) => am.state == 2)) {
      ToastUtils.show(S.of(context).g_key_feedback_2);
      return;
    }
    final fjStr = appendixs.map((am) => am.url).join(';');
    var completedWithExit = false;
    try {
      setState(() => load = Load.loading);
      final walletService = ServiceLocatorSetup.walletService;
      var address = "";
      if (walletService != null) {
        final mainWallet = walletService.getMainWallet();
        if (mainWallet != null) {
          address =
              await walletService.getChainAddress(
                mainWallet.address,
                CoinType.N.name,
              ) ??
              "";
        }
      }
      final mm = await UserInfoApi().submitFeedback(address, content, fjStr);
      if (!mounted) return;
      if (!mm.error && mm.data['code'] == 200) {
        ToastUtils.show(S.of(context).g_key_feedback_4);
        completedWithExit = true;
        Navigator.pop(context);
      } else {
        ToastUtils.show(S.of(context).g_key_feedback_3);
      }
    } catch (_) {
      if (mounted) {
        ToastUtils.show(S.of(context).g_key_feedback_3);
      }
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => load = Load.finish);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_key_feedback,
          actions: [
            if (load == Load.loading)
              Container(
                width: ScreenUtil().setWidth(40.0),
                alignment: Alignment.center,
                child: SizedBox(
                  width: ScreenUtil().setWidth(40.0),
                  height: ScreenUtil().setWidth(40.0),
                  child: const CircularProgressIndicator(),
                ),
              )
            else
              TextButton(
                onPressed: submit,
                child: Text(
                  S.of(context).g_key_154,
                  style: TextStyle(
                    color: _color(AppThemeKeys.mainButtonBgColor),
                    fontSize: ScreenUtil().setWidth(30.0),
                  ),
                ),
              ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildFeedbackInput(), _buildAttachmentList()],
            ),
          ),
        ),
      ),
    );
  }

  /// Shorthand for theme color lookup.
  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  /// Standard small border radius used across the page.
  BorderRadius get _borderRadius =>
      BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0)));

  Widget _buildFeedbackInput() {
    final pad = ScreenUtil().setWidth(30.0);
    final textColor = _color(AppThemeKeys.mainTextColor);

    return Container(
      margin: EdgeInsets.only(bottom: pad),
      padding: EdgeInsets.all(pad),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: _color(AppThemeKeys.itemBgColor),
        borderRadius: _borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_feedback,
            style: TextStyle(color: textColor, fontSize: pad),
          ),
          Container(
            padding: EdgeInsets.all(pad),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              color: _color(AppThemeKeys.backGroundColor),
              borderRadius: _borderRadius,
            ),
            child: TextField(
              style: TextStyle(color: textColor),
              controller: inputEditingController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: S.of(context).g_key_feedback_1,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              maxLines: 10,
              maxLength: 2000,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentList() {
    final pad = ScreenUtil().setWidth(30.0);

    return Container(
      padding: EdgeInsets.only(left: pad, right: pad, bottom: pad),
      decoration: BoxDecoration(
        color: _color(AppThemeKeys.itemBgColor),
        borderRadius: _borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_feedback_5,
                style: TextStyle(
                  color: _color(AppThemeKeys.mainTextColor),
                  fontSize: pad,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (appendixs.length >= 5) return;
                  selectFileDialog();
                },
                icon: const Icon(Icons.add),
                color: _color(AppThemeKeys.mainButtonBgColor),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: _color(AppThemeKeys.backGroundColor),
              borderRadius: _borderRadius,
            ),
            constraints: BoxConstraints(
              maxHeight: ScreenUtil().setWidth(600.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_feedback_6,
                  style: TextStyle(
                    color: _color(AppThemeKeys.itemSubtitleTextColor),
                    fontSize: pad,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(20.0)),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appendixs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (_, index) =>
                        _buildAttachmentItem(appendixs[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an inset overlay Positioned matching the attachment thumbnail bounds.
  Positioned _insetOverlay(double inset, {required Widget child}) {
    return Positioned(
      top: inset,
      bottom: inset,
      left: inset,
      right: inset,
      child: child,
    );
  }

  Widget _buildAttachmentItem(AppendixModel am) {
    final imgWidget = am.imgMini == null
        ? Image.file(File(am.path), fit: BoxFit.cover)
        : Image.memory(am.imgMini!, fit: BoxFit.cover);
    final inset = ScreenUtil().setWidth(10.0);
    final borderRadius = BorderRadius.all(
      Radius.circular(ScreenUtil().setWidth(20.0)),
    );
    final smallFont = ScreenUtil().setWidth(26.0);
    final accentColor = _color(AppThemeKeys.mainButtonBgColor);

    return Stack(
      children: [
        _insetOverlay(
          inset,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: _color(AppThemeKeys.itemBgColor),
              borderRadius: borderRadius,
            ),
            child: imgWidget,
          ),
        ),
        if (am.state == 1)
          _insetOverlay(
            inset,
            child: Container(
              decoration: BoxDecoration(
                color: _color(AppThemeKeys.transparentBgColor),
                borderRadius: borderRadius,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20.0),
                    ),
                    child: LinearProgressIndicator(
                      backgroundColor: _color(AppThemeKeys.mainGreyColor),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      value: am.upCount == 0 ? 0 : am.upCount / am.upTotal,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(10.0)),
                  Text(
                    '${am.upCount == 0 ? 0 : regular.formartNum((am.upCount / am.upTotal) * 100, 0)}%',
                    style: TextStyle(fontSize: smallFont, color: accentColor),
                  ),
                ],
              ),
            ),
          ),
        if (am.state == 3)
          _insetOverlay(
            inset,
            child: InkWell(
              onTap: () {
                uploadFile(am);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _color(AppThemeKeys.errorBgColor2),
                  borderRadius: borderRadius,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).g_key_feedback_7,
                      style: TextStyle(
                        fontSize: smallFont,
                        color: _color(AppThemeKeys.errorTextColor),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(10.0)),
                    Text(
                      S.of(context).g_key_feedback_8,
                      style: TextStyle(
                        fontSize: smallFont,
                        color: _color(AppThemeKeys.errorTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 0,
          right: 0,
          height: ScreenUtil().setWidth(60.0),
          width: ScreenUtil().setWidth(60.0),
          child: InkWell(
            onTap: () {
              deleteFile(am);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _color(AppThemeKeys.transparentBgColor),
                borderRadius: BorderRadius.all(
                  Radius.circular(ScreenUtil().setWidth(30.0)),
                ),
              ),
              child: Icon(
                Icons.close_outlined,
                color: _color(AppThemeKeys.mainWhiteColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void selectFileDialog() {
    FocusScope.of(context).unfocus();
    final textColor = _color(AppThemeKeys.mainTextColor);
    final optionStyle = TextStyle(
      color: textColor,
      fontSize: ScreenUtil().setWidth(32.0),
      height: 1.5,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(
            S.of(ctx).g_key_nft_18,
            style: TextStyle(color: textColor),
          ),
          children: [
            SimpleDialogOption(
              child: Text(S.of(ctx).g_key_nft_17, style: optionStyle),
              onPressed: () {
                getFile(0);
                Navigator.of(ctx).pop();
              },
            ),
            SimpleDialogOption(
              child: Text(S.of(ctx).g_key_nft_47, style: optionStyle),
              onPressed: () {
                getFile(1);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
