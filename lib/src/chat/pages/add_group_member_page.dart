import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_data.dart';
import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/widgets/contact_image.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:web3dart/crypto.dart';

class AddGroupMemberPage extends StatefulWidget {
  final String groupId;
  final List<GroupMemberInfo> groupMemberList;

  const AddGroupMemberPage(
      {super.key, required this.groupId, required this.groupMemberList});

  @override
  State<AddGroupMemberPage> createState() => _AddGroupMemberPageState();
}

class _AddGroupMemberPageState extends State<AddGroupMemberPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }
  ChatUtil? chatUtils;
  ChatUtil get _chatUtils{
    chatUtils ??= ChatUtil();
    return chatUtils!;
  }
  List<FriendInfo> friendList = [];
  List<FriendInfo> selectedList = [];

  late List<GroupMemberInfo> _groupMemberList;

  Load load=Load.finish;

  //群密码
  String? groupPwd;

  @override
  void initState() {
    _groupMemberList = widget.groupMemberList;
    super.initState();
    getFriendList();
    //获取群密码
    getGroupPwd();
  }

  //找出好友列表中已经进群的好友 进行标记 不能点击
  Future<void> checkExistsFriends() async {
    try {
      for (var element in friendList) {
        final flag = _groupMemberList.any((e) => e.memberId == element.uuid);
        if (flag) {
          element.isCanSelected = false;
        }
      }
    } catch (err) {
      //err:
    }
  }

  Future<void> getGroupPwd() async {
    try {
      // 从缓存取出group pwd
      GroupData? gd = await ChatSPUtil().getGroupDataByGroupId(widget.groupId);
      if (gd != null) {
        groupPwd = gd.groupPwd;
      } else {
        final data = await chatApi.checkGroupSSById(widget.groupId);
        if (data != null && data['code'] == 200) {
          final map = data["data"];
          if (map != null) {
            final pubKey = map["public_key"];
            final ss = map["ss"];
            //兼容多钱包 根据pubKey找出对应钱包的privateKey
            // Use IChatCryptoService instead of WalletActionProvider
            final cryptoService = ServiceLocatorSetup.chatCryptoService;
            Map<String, String> keyMap = {};
            if (cryptoService != null) {
              keyMap = await cryptoService.getPublicKeyAndPrivateKeyPairs();
            }
            final privateKey = keyMap["$pubKey"];
            if (privateKey == null) {
              return;
            }
            final decode = await _chatUtils.chatDecode(
                privateKey, Base64Utils().decodeBase64(ss));
            groupPwd = dataUtils.toStringFromHex(decode ?? '');
            debugPrint("解密出的群密码是：$groupPwd"); //eDJHBgiQgN8aWwsN
            //保存group pwd
            ChatSPUtil().saveGroupDataIfNotExists(
                GroupData(widget.groupId, groupPwd ?? ''));
          }
        }
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }

  Future<void> getFriendList() async {
    try {
      setState(() {
        load=Load.loading;
      });
      final data = await chatApi.friendList();
      if (data != null && data["code"] == 200) {
        friendList =
            (data["data"] as List).map((e) => FriendInfo.fromJson(e)).toList();

        // 返回列表中 把自己排除在外
        friendList.removeWhere(
                (element) => element.uuid == AppGlobals.userInfo?.uuid);
        if (friendList.isNotEmpty) {
          await checkExistsFriends();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          load=Load.finish;
        });
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
    return "${AppGlobals.userInfo?.name}、$name";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_11,
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
                      S.of(context).g_chat_key_12,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(30)),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemLineColor.name),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    FriendInfo model = friendList[index];
                    return GestureDetector(
                      onTap: () async {
                        if (model.isCanSelected != null &&
                            !model.isCanSelected!) {
                          return;
                        }
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
                                // (model.isCanSelected != null && !model.isCanSelected!) ?const Color(0xff888888):
                                Container(
                                  width: ScreenUtil().setWidth(48),
                                  height: ScreenUtil().setWidth(48),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: model.isSelected
                                        ? const Color(0xff32D74B)
                                        : (model.isCanSelected != null &&
                                        !model.isCanSelected!)
                                        ? AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.ff888888.name)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: model.isSelected
                                          ? Colors.transparent
                                          : AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.ff888888.name),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: model.isSelected ||
                                      (model.isCanSelected != null &&
                                          !model.isCanSelected!)
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
                                                    // fontWeight: FontWeight.bold,
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
                                  context, AppThemeKeys.itemLineColor.name),
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
                      if (selectedList.isEmpty) {
                        return;
                      }

                      if (groupPwd == null) {
                        //丢失群加密key,无法邀请他人进群
                        ToastUtils.show(
                            "The group encryption key is lost, and others cannot be invited to the group");
                        return;
                      }

                      setState(() {
                        load=Load.loading;
                      });

                      List<String?> groupMemberIds =
                      selectedList.map((e) => e.uuid).toList();

                      final data = await chatApi.addGroupMembers(widget.groupId,
                          AppGlobals.userInfo?.uuid ?? '', groupMemberIds);

                      if (data == null) {
                        ToastUtils.show("Network error");
                        return;
                      }

                      if (data["code"] != 200) {
                        // 显示具体错误信息
                        String errorMsg = data["msg"] ?? "Invite failed";
                        if (data["data"] != null && data["data"] is Map) {
                          final errorData = data["data"] as Map;
                          if (errorData.isNotEmpty) {
                            errorMsg = errorData.values.first?.toString() ?? errorMsg;
                          }
                        }
                        ToastUtils.show(errorMsg);
                        return;
                      }

                      // code == 200, 邀请成功
                      {
                        //更新会话列表
                        eventBus.fire(EventPublic(
                            EventPublicType.updateChatConversationList));

                        //对群成员生成群成员
                        Map<String, dynamic> params = {};

                        for (var element in selectedList) {
                          final pubKey = element.publicKey;
                          final ssText = await _chatUtils.chatEnCode(
                            pubKey ?? '',
                            bytesToHex(Uint8List.fromList(groupPwd!.codeUnits)),
                          );
                          params["${element.uuid}"] =
                              Base64Utils().encodeBase64(ssText ?? '');
                        }

                        final uploadSSData = await chatApi.uploadGroupMemberSS(
                            widget.groupId, params);
                        if (!mounted) return;
                        if (uploadSSData != null && uploadSSData["code"] == 200) {
                          Navigator.of(this.context).pop(true);
                        }
                      }
                    } catch (err) {
                      debugPrint("err : ${err.toString()}");
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
                        color: selectedList.isEmpty
                            ? AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name)
                            : Colors.green,
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12))),
                    child: Text(
                      "${S.of(context).g_chat_key_13}(${selectedList.length})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
        ),
      ),
    );
  }
}