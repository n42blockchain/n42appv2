import 'dart:io';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/home/models/appendix_model.dart';
import 'package:n42_wallet/core/network/ipfs_api.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/di/service_locator_setup.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as f_picker;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_compress/video_compress.dart';

class Feedback extends StatefulWidget {
  const Feedback({super.key});

  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  Regular? _regular;
  Regular get regular {
    _regular ??= Regular();
    return _regular!;
  }

  TextEditingController inputEditingController = TextEditingController();
  Load load = Load.finish;
  List<AppendixModel> appendixs = [];

  @override
  void dispose() {
    inputEditingController.dispose();
    super.dispose();
  }

  /// 选择文件，type: 0=图片，1=视频
  Future<void> getFile(int type) async {
    f_picker.FilePickerResult? result = await f_picker.FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: type == 0 ? f_picker.FileType.image : f_picker.FileType.video,
    );
    if (result == null) return;
    int fjCount = result.files.length;
    if (fjCount > 5) fjCount = 5 - appendixs.length;

    for (int i = 0; i < fjCount; i++) {
      f_picker.PlatformFile pf = result.files[i];
      AppendixModel am = AppendixModel();
      am.name = pf.name;
      am.path = pf.path.toString();
      am.upTotal = pf.size;
      if (type == 1) {
        await createVideoImageMini(am);
      }
      appendixs.add(am);
      uploadFile(am);
    }
    setState(() {});
  }

  Future<void> createVideoImageMini(AppendixModel am) async {
    am.imgMini = await VideoCompress.getByteThumbnail(
      am.path,
      quality: 25,
      position: -1,
    );
    setState(() {});
  }

  Future<void> uploadFile(AppendixModel am) async {
    try {
      File file = File(am.path);
      am.cancelToken = CancelToken();
      setState(() {
        am.state = 1;
        am.upCount = 0;
        am.upTotal = 0;
      });
      Map<String, dynamic> rData = await IpfsApi().uploadIPFSImage(
        file.path,
        "fkImage.png",
        (int count, int total) {
          am.upCount = count;
          am.upTotal = total;
          setState(() {});
        },
        cancelToken: am.cancelToken,
      );
      setState(() {
        if (rData["error"]) {
          am.state = 3;
        } else {
          am.url = "${AppConfig.apiUrl['ipfsAddress']}${rData['data']['Hash']}";
          am.state = 2;
        }
      });
    } catch (e) {
      setState(() {
        am.state = 3;
      });
    }
  }

  void deleteFile(AppendixModel am) {
    if (am.state == 1) am.cancelToken!.cancel();
    appendixs.remove(am);
    setState(() {});
  }

  Future<void> submit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    String content = inputEditingController.text;
    if (content == "") {
      ToastUtils.show(S.of(context).g_key_feedback_1);
      return;
    }
    bool fjUpload = true;
    String fjStr = "";
    for (AppendixModel am in appendixs) {
      if (am.state != 2) {
        fjUpload = false;
        break;
      }
      fjStr += "${am.url};";
    }
    if (fjUpload == false) {
      ToastUtils.show(S.of(context).g_key_feedback_2);
      return;
    }
    setState(() { load = Load.loading; });
    final walletService = ServiceLocatorSetup.walletService;
    String address = "";
    if (walletService != null) {
      final mainWallet = walletService.getMainWallet();
      if (mainWallet != null) {
        address = await walletService.getChainAddress(mainWallet.address, CoinType.N.name) ?? "";
      }
    }
    MessageModel mm = await UserInfoApi().submitFeedback(address, content, fjStr);
    setState(() { load = Load.finish; });
    if (!mounted) return;
    if (mm.error) {
      ToastUtils.show(S.of(context).g_key_feedback_3);
    } else {
      if (mm.data['code'] == 200) {
        ToastUtils.show(S.of(context).g_key_feedback_4);
        Navigator.pop(context);
      } else {
        ToastUtils.show(S.of(context).g_key_feedback_3);
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setWidth(30.0),
                  ),
                ),
              ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeedbackInput(),
                _buildAttachmentList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackInput() {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_feedback,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setWidth(30.0),
            ),
          ),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
            ),
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
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
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
        bottom: ScreenUtil().setWidth(30.0),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
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
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setWidth(30.0),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (appendixs.length >= 5) return;
                  selectFileDialog();
                },
                icon: const Icon(Icons.add),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
            ),
            constraints: BoxConstraints(maxHeight: ScreenUtil().setWidth(600.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_feedback_6,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setWidth(30.0),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(20.0)),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appendixs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return _buildAttachmentItem(appendixs[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(AppendixModel am) {
    final imgWidget = am.imgMini == null
        ? Image.file(File(am.path), fit: BoxFit.cover)
        : Image.memory(am.imgMini!, fit: BoxFit.cover);
    final inset = ScreenUtil().setWidth(10.0);
    final radius = ScreenUtil().setWidth(20.0);

    return Stack(
      children: [
        Positioned(
          top: inset, bottom: inset, left: inset, right: inset,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            child: imgWidget,
          ),
        ),
        if (am.state == 1)
          Positioned(
            top: inset, bottom: inset, left: inset, right: inset,
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.transparentBgColor.name),
                borderRadius: BorderRadius.all(Radius.circular(radius)),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    child: LinearProgressIndicator(
                      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainGreyColor.name),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name)),
                      value: am.upCount == 0 ? 0 : am.upCount / am.upTotal,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(10.0)),
                  Text(
                    '${am.upCount == 0 ? 0 : regular.formartNum((am.upCount / am.upTotal) * 100, 0)}%',
                    style: TextStyle(
                      fontSize: ScreenUtil().setWidth(26.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (am.state == 3)
          Positioned(
            top: inset, bottom: inset, left: inset, right: inset,
            child: InkWell(
              onTap: () { uploadFile(am); },
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).g_key_feedback_7,
                      style: TextStyle(
                        fontSize: ScreenUtil().setWidth(26.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(10.0)),
                    Text(
                      S.of(context).g_key_feedback_8,
                      style: TextStyle(
                        fontSize: ScreenUtil().setWidth(26.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 0, right: 0,
          height: ScreenUtil().setWidth(60.0),
          width: ScreenUtil().setWidth(60.0),
          child: InkWell(
            onTap: () { deleteFile(am); },
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.transparentBgColor.name),
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30.0))),
              ),
              child: Icon(Icons.close_outlined,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name)),
            ),
          ),
        ),
      ],
    );
  }

  void selectFileDialog() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            S.of(context).g_key_nft_18,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                S.of(context).g_key_nft_17,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setWidth(32.0),
                  height: 1.5,
                ),
              ),
              onPressed: () {
                getFile(0);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              child: Text(
                S.of(context).g_key_nft_47,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setWidth(32.0),
                  height: 1.5,
                ),
              ),
              onPressed: () {
                getFile(1);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
