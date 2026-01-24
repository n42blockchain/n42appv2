import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/utils/password_gen.dart';
import 'package:n42appv2/src/chat/widgets/contact_image.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  ChatUtil? _chatUtils;
  ChatUtil get chatUtils{
    _chatUtils ??= ChatUtil();
    return _chatUtils!;
  }
  List<FriendInfo> friendList = [];
  List<FriendInfo> selectedList = [];
  //bool isLoading = false;
  Load load=Load.finish;

  @override
  void initState() {
    super.initState();
    getFriendList();
  }

  getFriendList() async {
    try {
      load = Load.loading;
      setState(() {});
      final data = await chatApi.friendList();
      if (data != null && data["code"] == 200) {
        friendList =
            (data["data"] as List).map((e) => FriendInfo.fromJson(e)).toList();

        // 返回列表中 把自己排除在外
        friendList.removeWhere(
                (element) => element.uuid == AppGlobals.userInfo?.uuid);
      }
    } finally {
      if (mounted) {
        load = Load.finish;
        setState(() {});
      }
    }
  }

  String generateGroupName() {
    if (selectedList.isEmpty) return '';
    int limit = 2;
    String name = '';
    if (selectedList.length >= limit) {
      for (int i = 0; i < limit; i++) {
        name += "${selectedList[i].name}、";
      }
    }
    name=name.substring(0,name.length-1);
    return "${AppGlobals.userInfo?.name}、$name";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_1,
      ),
      body: SafeArea(
        child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(40), horizontal: ScreenUtil().setWidth(32)),
                    child: Text(
                      S.of(context).g_chat_key_14,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32)),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.dividerColor.name),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    FriendInfo model = friendList[index];
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          model.isSelected = !model.isSelected;
                          if (model.isSelected) {
                            selectedList.add(model);
                          } else {
                            selectedList.remove(model);
                          }
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(24),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(48),
                                  height: ScreenUtil().setWidth(48),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: model.isSelected
                                        ? const Color(0xff32D74B)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: model.isSelected
                                          ? Colors.transparent
                                          : AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.ff888888.name),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: model.isSelected
                                      ? Icon(
                                    Icons.check,
                                    size: ScreenUtil().setWidth(40),
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(24),
                                ),
                                Expanded(
                                    child: Row(
                                      children: [
                                        ContactImage(
                                          faceUrl: model.image ?? '',
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setWidth(32),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              // name
                                              Text(
                                                model.name ?? '',
                                                style: TextStyle(
                                                    color:
                                                    AppThemeUtils.getColorByKey(
                                                        context,
                                                        AppThemeKeys
                                                            .mainTextColor.name),
                                                    fontSize: ScreenUtil().setSp(30)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                height: ScreenUtil().setWidth(20),
                                              ),
                                              //email
                                              Row(
                                                children: [
                                                  Text(
                                                    'E-mail: ',
                                                    style: TextStyle(
                                                        color: Color(0xFFC1C0C9),
                                                        fontSize: ScreenUtil().setSp(30)),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      model.email ?? '',
                                                      style: TextStyle(
                                                          color: Color(0xFFC1C0C9),
                                                          fontSize: ScreenUtil().setSp(30)),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Divider(
                              height: 0.5,
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.dividerColor.name),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: friendList.length,
                ),
              ),
              Container(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(24)),
                width: double.infinity,
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      if(load==Load.loading)return;
                      if (selectedList.isEmpty || selectedList.length < 2) {
                        return;
                      }

                      setState(() {
                        load=Load.loading;
                      });

                      List<String?> groupMemberIds =
                      selectedList.map((e) => e.uuid).toList();

                      final groupName = generateGroupName();

                      final data = await chatApi.createGroup('', groupName, '',
                          AppGlobals.userInfo?.uuid ?? '', groupMemberIds);

                      if (data != null && data["code"] == 200) {
                        final groupId = data["data"];

                        //更新会话列表
                        eventBus.fire(EventPublic(
                            EventPublicType.updateChatConversationList));

                        //随机生成群消息解密密码 使用pub key 加密 上到到服务器
                        String passWord = generatePassword();
                        String? mPubKey = await chatUtils.getAstPubKey();
                        final mSecrtData = await chatUtils.chatEnCode(
                            mPubKey ?? '',
                            bytesToHex(Uint8List.fromList(passWord.codeUnits)));

                        //对群成员生成群成员
                        Map<String, dynamic> params = {};
                        params["${AppGlobals.userInfo?.uuid}"] =
                            Base64Utils().encodeBase64(mSecrtData ?? '');

                        for (var element in selectedList) {
                          final pubKey = element.public_key;
                          final ssText = await chatUtils.chatEnCode(
                              pubKey ?? '',
                              bytesToHex(Uint8List.fromList(passWord.codeUnits)));
                          params["${element.uuid}"] =
                              Base64Utils().encodeBase64(ssText ?? '');
                        }
                        final uploadSSData =
                        await chatApi.uploadGroupMemberSS(groupId, params);
                        if (!mounted) return;
                        if (uploadSSData != null && uploadSSData["code"] == 200) {
                          Navigator.of(this.context).pop();
                        }

                      }
                    } catch (_) {
                      // 创建群组过程中的错误安全忽略，finally 块会重置加载状态
                    } finally {
                      setState(() {
                        load=Load.finish;
                      });
                    }
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12), horizontal: ScreenUtil().setWidth(24)),
                    decoration: BoxDecoration(
                        color: selectedList.isEmpty || selectedList.length < 2
                            ? AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name)
                            : Colors.green,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "${S.of(context).g_chat_key_13}(${selectedList.length})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}
