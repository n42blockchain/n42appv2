import 'dart:convert';
import 'dart:io';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_data.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_data_util.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/widgets/chat_delete_dialog.dart';
import 'package:n42appv2/src/chat/widgets/file_aes_crypt_utils.dart';
import 'package:n42appv2/src/chat/widgets/file_utils.dart';
import 'package:n42appv2/src/chat/widgets/report_post.dart';
import 'package:n42appv2/src/chat/widgets/report_widget.dart';
import 'package:n42appv2/src/component/pages/show_image.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/widgets/file_icon.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/item_group_chat_reply_inner_widget.dart';
import 'package:n42appv2/src/widgets/reply_empty_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_compress/video_compress.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemGroupChatView extends StatefulWidget {
  final bool isCurrentUser;
  final ChatMessageModel item;
  final String? time;
  final String mPrivateKey;
  final dynamic type10OnTap;

  const ItemGroupChatView(
      {super.key,
        required this.isCurrentUser,
        required this.item,
        this.time,
        required this.mPrivateKey,
        this.type10OnTap});

  @override
  State<ItemGroupChatView> createState() => _ItemGroupChatViewState();
}

class _ItemGroupChatViewState extends State<ItemGroupChatView>
    with AutomaticKeepAliveClientMixin {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    _chatDBApi ??= ChatDBApi();
    return _chatDBApi!;
  }
  FileUtils? fileUtils;
  FileUtils get _fileUtils{
    fileUtils ??= FileUtils();
    return fileUtils!;
  }
  //1 = text 、2= video、3= image、Location = 4   File = 5  RedEnvelope = 10  Tip_Notification = 90 提示文本
  int messageType = 0;

  // Tip_Notification 消息不加密 不需要解析
  // 消息是否已经解析成功
  String? content = "";
  Uint8List? uint8list;

  late ChatMessageModel _item;

  String? name;
  String? image;

  //群密码
  String? groupPwd;

  bool isLoading = false;

  final CustomPopupMenuController controller = CustomPopupMenuController();

  //如果当前消息被举报 是否展示 默认都不展示
  bool showReportMessage = false;

  //当前消息回复的消息
  ChatMessageModel? replyChatItem;

  //当前消息是否有回复消息
  bool isReply = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    _item = widget.item;
    messageType = _item.content.type;
    isReply = _item.replyId != null;
    await getGroupPwd();
    await findReplyMessage();
    handlerMessage();
    updateUserInfo();
  }

  Future<void> findReplyMessage() async {
    try {
      if (isReply) {
        replyChatItem =
        await chatDBApi.getMessageByMessageId(_item.replyId!);
        debugPrint("replyChatItem ${replyChatItem != null}");
      }
    } catch (err) {
      debugPrint("findReplyMessage err:${err.toString()}");
    }
  }

  Future<void> getGroupPwd() async {
    try {
      GroupData? gd =
      await ChatSPUtil().getGroupDataByGroupId(_item.getTargetId());
      if (gd != null) {
        groupPwd = gd.groupPwd;
        // debugPrint("ItemGroupChatView group pwd：$groupPwd"); //eDJHBgiQgN8aWwsN
      } else {
        final data = await chatApi.checkGroupSSById(_item.getTargetId());
        if (data != null && data['code'] == 200) {
          final map = data["data"];
          if (map != null) {
            final pubKey = map["public_key"];
            final ss = map["ss"];

            ///兼容多钱包 根据pubKey找出对应钱包的privateKey
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
            final decode = await ChatUtil().chatDecode(
                privateKey, Base64Utils().decodeBase64(ss));
            groupPwd = DataUtils().toStringFromHex(decode ?? '');
            ChatSPUtil().saveGroupDataIfNotExists(
                GroupData(_item.getTargetId(), groupPwd ?? ''));
          }
        }
      }
    } catch (_) {
      // 获取群密码失败时安全忽略，无法解密消息时显示默认图标
    }
  }

  //用户头像渲染
  Future<void> updateUserInfo() async {
    try {
      if (widget.isCurrentUser) {
        name = AppGlobals.userInfo?.name;
        image = AppGlobals.userInfo?.image;
      } else {
        final targetId = _item.from;
        FriendInfo? info = await ChatSPUtil().getNavUserInfo(targetId);
        if (info != null) {
          name = info.name;
          image = info.image;
        } else {
          final friendData = await chatApi.getUserInfo(targetId);
          if (friendData != null && friendData["code"] == 200) {
            FriendInfo fInfo = FriendInfo.fromJson(friendData["data"]);
            name = fInfo.name;
            image = fInfo.image;
            //更新缓存
            ChatSPUtil().saveOrUpdateUserInfo(fInfo);
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // 更新用户信息失败时安全忽略，使用默认头像
    }
  }

  Future<void> handlerMessage() async {
    try {
      isLoading = true;
      if (messageType == 90) {
        // 0 单聊 1群组
        if (_item.conversationType == 1) {
          ChatDataUtil chatDataUtils=ChatDataUtil();
          _item.content.pushContent2 ??= await chatDataUtils.generateGroupTips(
              json.decode(_item.content.pushContent ?? ''));
          content = _item.content.pushContent2;
          widget.item.content.pushContent2 = content;
          //update db
          chatDBApi.updateMessage(_item);
        } else {
          content = _item.content.content;
        }
        if (mounted) {
          setState(() {});
        }
      }
      else {
        // 其他消息类型需要解密操作
        if (messageType == 1) {
          //暂时不加密 进行测试
          // content = _item.content.searchableContent;
          //文本消息
          if (_item.decryptionMessageContent != null) {
            //已经解密
            content = _item.decryptionMessageContent;
          } else {
            try {
              final encyMessage = _item.content.searchableContent;
              // debugPrint("encyMessage ： $encyMessage");
              //解密消息
              if (groupPwd == null) {
                debugPrint(
                    "The decryption password is empty and the message cannot be decrypted");
                return;
              }
              final messageContent =
              AesUtils().aesDecrypted(encyMessage ?? '', groupPwd!);

              content = messageContent;

              //更新数据库、内存
              widget.item.decryptionMessageContent = content;
              _item.decryptionMessageContent = content;

              await chatDBApi.updateMessage(_item);

              if (mounted) {
                setState(() {});
              }
            } catch (_) {
              // 文本消息解密失败时安全忽略，显示默认图标
            }
          }
        }else if(messageType == 10){
          if (_item.decryptionMessageContent != null) {
            //已经解密
            content = _item.decryptionMessageContent;
          } else {
            try {
              final encyMessage = _item.content.searchableContent;
              //解密消息
              if (groupPwd == null) {
                return;
              }
              final messageContent =
              AesUtils().aesDecrypted(encyMessage ?? '', groupPwd!);

              content = messageContent;

              //更新数据库、内存
              widget.item.decryptionMessageContent = content;
              _item.decryptionMessageContent = content;

              await chatDBApi.updateMessage(_item);

              if (mounted) {
                setState(() {});
              }
            } catch (_) {
              // 红包消息解密失败时安全忽略，显示默认图标
            }
          }
        }
        else {
          String? filePath = _item.decryptionMessageContent;
          if (filePath != null) {
            //如果数据库中保存的路径文件 已经删除 则需要重新下载更新
            if (!await File(filePath).exists()) {
              _item.decryptionMessageContent = null;
            } else {
              //debugPrint("文件存在 不需要从新下载");
            }
          }

          if (_item.decryptionMessageContent != null) {
            //已经解密
            content = _item.decryptionMessageContent;
            if (messageType == 6) {
              //video first layer
              uint8list = await VideoCompress.getByteThumbnail(
                  content!,
                  quality: 60, // default(100)
                  position: -1 // default(-1)
              );
            }
            setState(() {});
          } else {
            // 1 下载
            // 2 解密
            // 3 更新数据库本地文件路径
            final fileUrl = _item.content.searchableContent;
            final fileName = _item.content.originalFileName;
            debugPrint("fileUrl ： $fileUrl");
            debugPrint("fileName ： $fileName");
            if (fileName == null || fileUrl == null) return;

            String savePath = await _fileUtils.getTempDirByName(fileName);
            debugPrint("savePath : $savePath");


            ///Perform file download
            ///// https://ipfs.infura.io/ipfs/QmVEbHPksyCcTGNajMm8QThSiB9AvSWpYGCssnhnKuzwtY 图片
            //FileApi fileApi=FileApi();
            final fileData = await IpfsApi().downLoadFile(fileUrl, savePath,
                receiveProgress: (int count, int total) {
                });

            if (fileData) {
              ///2、使用群密码解密文件
              if (groupPwd == null) {
                return;
              }

              final newPath = await FileAesCryptUtils().isolateDecryptFile(
                  savePath, groupPwd!);

              if (newPath != null) {
                content = newPath;
                //更新数据库、内存
                widget.item.decryptionMessageContent = content;
                _item.decryptionMessageContent = content;
                chatDBApi.updateMessage(_item);

                if (messageType == 6) {
                  uint8list = await VideoCompress.getByteThumbnail(
                      content!,
                      quality: 60, // default(100)
                      position: -1 // default(-1)
                  );
                }

                setState(() {});
              } else {
                // 文件解密失败时安全忽略，显示默认图标
              }
            }
          }
        }
      }
    } catch (_) {
      // 消息处理过程中的错误安全忽略，显示默认图标
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.time != null)
          Container(
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(32)),
              ),
              child: Container(
                padding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12), horizontal: ScreenUtil().setWidth(24)),
                child: Text(
                  widget.time!,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(24)),
                ),
              ),
            ),
          ),

        //渲染提示文本
        if (messageType == 90)
          Container(
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12), horizontal: ScreenUtil().setWidth(40)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // color: AppThemeUtils.getColorByKey(
                //     context, AppThemeKeys.mainBoxColor),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ScreenUtil().setSp(32)),
              ),
              child: Container(
                padding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12), horizontal: ScreenUtil().setWidth(24)),
                child: Text(
                  content ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(24)),
                ),
              ),
            ),
          ),
        if (messageType != 90)
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.isCurrentUser ? 64.0 : 16.0,
              12,
              widget.isCurrentUser ? 16.0 : 64.0,
              12,
            ),
            child: Align(
              // align the child within the container
              alignment: widget.isCurrentUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: CustomPopupMenu(
                verticalMargin: ScreenUtil().setWidth(12),
                pressType: PressType.longPress,
                controller: controller,
                arrowColor: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    // 解析消息失败时 点击继续解析消息
                    if (content != null && messageType != 0) {
                      if (messageType == 3) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                ShowImage(" ", File(content!), type: "file",watermark:"")));
                      }else if(messageType == 10){
                        widget.type10OnTap();
                      } else {
                        OpenFilex.open(content!);
                      }
                    }
                    if (content == null ||
                        (content != null && content!.isEmpty)) {
                      if (!isLoading) {
                        ToastUtils.show("decryption failure");
                        handlerMessage();
                      }
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: wrapItem(),
                  ),
                ),
                menuBuilder: () {
                  return IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
                        color: const Color(0xffFEFEFE),
                      ),
                      width: ScreenUtil().setWidth(500),
                      child: Column(
                        children: [
                          ///消息回复
                          if (content != null)
                            GestureDetector(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(36)),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          Text(S.of(context).g_chat_key_66,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ScreenUtil().setSp(32))),
                                          const Spacer(),
                                          Image.asset(
                                              "assets/chat/huifu.png",
                                              width: ScreenUtil().setWidth(48),
                                              fit: BoxFit.cover)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.itemLineColor.name),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                controller.hideMenu();
                                eventBus.fire(EventPublic(
                                    EventPublicType.chatItemReply,
                                    param: _item));
                              },
                            ),

                          GestureDetector(
                              onTap: () async {
                                controller.hideMenu();
                                sheetBottom(
                                  context,
                                  "",
                                  ReportWidget(
                                    name: name ?? '',
                                    // reportAndBlockCallBack: () {
                                    //   Navigator.of(context).pop();
                                    // },
                                    reportCallBack: () {
                                      Navigator.of(context).pop();
                                      final controller =
                                      TextEditingController();
                                      //底部弹出举报框
                                      sheetBottom(
                                          context,
                                          isDismissible: false,
                                          "",
                                          ReportPost(
                                            name: name ?? '',
                                            messageId: "${_item.messageId}",
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              try {
                                                final reason =
                                                controller.text.trim();
                                                final data =
                                                await chatApi.reportUser(
                                                  reason,
                                                  messageId: _item.messageId,
                                                );
                                                //{code: 200, msg: OK, data: true}
                                                if (data != null &&
                                                    data["code"] == 200 &&
                                                    data["data"]) {
                                                  // ToastUtils.showFtToast();
                                                  ToastUtils.show(
                                                      "report success");
                                                  //更新数据库 当前消息已经被举报
                                                  _item.content.reportType = 1;
                                                  chatDBApi.updateMessage(
                                                      _item);
                                                  setState(() {
                                                    showReportMessage = false;
                                                  });
                                                }
                                              } finally {
                                                //debugPrint("");
                                              }
                                            },
                                            controller: controller,
                                          ));
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(36)),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Text(
                                        S.of(context).g_chat_key_40,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: ScreenUtil().setSp(32)),
                                      ),
                                      const Spacer(),
                                      Image.asset("assets/chat/flag.png",
                                          width: ScreenUtil().setWidth(48), fit: BoxFit.cover)
                                    ],
                                  ),
                                ),
                              )),
                          Divider(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemLineColor.name),
                          ),
                          if (messageType == 1)
                            GestureDetector(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(36)),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          Text(S.of(context).g_key_119,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ScreenUtil().setSp(32))),
                                          const Spacer(),
                                          Image.asset(
                                              "assets/chat/content_copy.png",
                                              width: ScreenUtil().setWidth(48),
                                              fit: BoxFit.cover)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.itemLineColor.name),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                controller.hideMenu();
                                //复制文本内容
                                if (content != null) {
                                  Clipboard.setData(
                                      ClipboardData(text: '$content'));
                                  ToastUtils.show(S.of(context).copy);
                                }
                              },
                            ),
                          GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(36)),
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Text(S.of(context).g_key_113,
                                        style: TextStyle(
                                            color: Color(0xffFE3B30),
                                            fontSize: ScreenUtil().setSp(32))),
                                    const Spacer(),
                                    Image.asset("assets/chat/delete.png",
                                        width: ScreenUtil().setWidth(48), fit: BoxFit.cover)
                                  ],
                                ),
                              ),
                            ),
                            onTap: () async {
                              controller.hideMenu();
                              sheetBottom(context, "", ChatDeleteDialog(
                                deleteCallBack: () async {
                                  Navigator.of(context).pop();
                                  final raw =
                                  await chatDBApi.deleteMessage(_item);
                                  if (raw != 0) {
                                    //更新列表
                                    eventBus.fire(EventPublic(
                                        EventPublicType.deleteChatItem,
                                        param: _item));
                                  }
                                },
                              ));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // child: _buildItem(context),
            ),
          ),
      ],
    );
  }

  Widget wrapItem() {
    if (widget.isCurrentUser) {
      return IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildItem(context),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(24),
            ),
            GestureDetector(
              onLongPress: () {},
              onTap: () {},
              child: Container(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setWidth(80),
                //超出部分，可裁剪
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(40)),
                    border: Border.all(
                        width: 0.5,
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemLineColor.name))),
                child: ImageNetWork(
                  imageUrl: image ?? "",
                  placeholder: "assets/chat/user_def_icon.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {},
            onTap: () {},
            child: Container(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(80),
              //超出部分，可裁剪
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(40)),
                  border: Border.all(
                      width: 0.5,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemLineColor.name))),
              child: ImageNetWork(
                imageUrl: image ?? "",
                placeholder: "assets/chat/user_def_icon.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(24),
          ),
          Expanded(child: _buildItem(context))
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context) {
    BorderRadiusGeometry? borderRadius = widget.isCurrentUser
        ? const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(2))
        : const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(2),
        bottomRight: Radius.circular(8));

    if (content != null && content!.isNotEmpty) {
      //当前消息被举报
      if (_item.content.reportType == 1 && !showReportMessage) {
        return IntrinsicWidth(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showReportMessage = !showReportMessage;
                });
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.isCurrentUser
                      ? const Color(0xff1976F9)
                      : Colors.grey[300],
                  borderRadius: borderRadius,
                ),
                child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                    child: Text(
                      S.of(context).g_chat_key_57,
                      style: TextStyle(
                          color:
                          widget.isCurrentUser ? Colors.white : Colors.black87
                      ),
                    )),
              ),
            ));
      }

      if (messageType == 1) {
        return IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildMessageStatus(),
              Expanded(
                child: DecoratedBox(
                  // chat bubble decoration
                  decoration: BoxDecoration(
                    color: widget.isCurrentUser
                        ? const Color(0xff1976F9)
                        : Colors.grey[300],
                    borderRadius: borderRadius,
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //回复消息
                          buildReplyInnerWidget(),

                          Text(
                            content!,
                            style: TextStyle(
                                color: widget.isCurrentUser
                                    ? Colors.white
                                    : Colors.black87
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        );
      }
      else if (messageType == 3) {
        //image 类型
        return IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildMessageStatus(),
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                child: Container(
                    width: ScreenUtil().setWidth(180),
                    height: ScreenUtil().setWidth(160),
                    decoration: BoxDecoration(
                      // color:
                      //     widget.isCurrentUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Image.file(
                      File(content!),
                      width: ScreenUtil().setWidth(180),
                      height: ScreenUtil().setWidth(160),
                      fit: BoxFit.cover,
                    )),
              )
            ],
          ),
        );
      }
      else if (messageType == 6) {
        // video
        if (uint8list != null) {
          return IntrinsicWidth(
            child: Row(
              children: [
                buildMessageStatus(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: ScreenUtil().setWidth(180),
                    height: ScreenUtil().setWidth(160),
                    child: Stack(
                      children: [
                        Image.memory(
                          uint8list!,
                          width: ScreenUtil().setWidth(180),
                          height: ScreenUtil().setWidth(160),
                          fit: BoxFit.cover,
                        ),
                        Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.blueAccent,
                              size: ScreenUtil().setWidth(72),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
      else if (messageType == 10) {
        Map<String,dynamic> cMap=json.decode(content??"{}");
        //RedEnvelope 类型
        return IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildMessageStatus(),
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                child: Container(
                  width: ScreenUtil().setWidth(232),
                  height: ScreenUtil().setWidth(332),
                  decoration: BoxDecoration(
                    color: Color(0xffFA3F3F),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: ScreenUtil().setWidth(140),
                        child: Image.asset("assets/chat/redPocket1.png",fit: BoxFit.cover,),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              width: ScreenUtil().setWidth(72),
                              height: ScreenUtil().setWidth(72),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(72),),
                                color: Color(0xffFFDA44),
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/img/ast_nft.png",
                                height: ScreenUtil().setWidth(40),width: ScreenUtil().setWidth(40),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setWidth(20),),
                              height: ScreenUtil().setWidth(60),
                              child: Text(
                                cMap['note'],//"恭喜发财",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(24),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: ScreenUtil().setWidth(48),
                                    height: ScreenUtil().setWidth(48),
                                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
                                    ),
                                    child: ImageNetWork(
                                      imageUrl: cMap['avatar']??"",
                                      width: ScreenUtil().setWidth(48),
                                      placeholder: "assets/chat/user_def_icon.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    //width: 55,
                                    constraints: BoxConstraints(
                                      maxWidth: ScreenUtil().setWidth(110),
                                      minWidth: 0,
                                    ),
                                    child: Text(
                                      cMap['nickname']??"",
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setWidth(24),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setWidth(10),),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else {
        return IntrinsicWidth(
          child: Row(
            children: [
              buildMessageStatus(),
              Container(
                width: ScreenUtil().setWidth(180),
                padding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(16)),
                decoration: BoxDecoration(
                  color: widget.isCurrentUser ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FileIcon(
                      content!,
                      size: ScreenUtil().setWidth(48),
                      iconColor:
                      widget.isCurrentUser ? Colors.white : Colors.black87,
                    ),
                    Text(
                      _fileUtils.getFileNameByPath(content!),
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: widget.isCurrentUser
                              ? Colors.white
                              : Colors.black87,
                          fontSize: ScreenUtil().setSp(20)),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }

    //消息未解析成功时 显示默认图标
    return Container(
        height: ScreenUtil().setWidth(120),
        width: ScreenUtil().setWidth(180),
        decoration: BoxDecoration(
          color: widget.isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDefaultIcon(),
          ],
        ));
  }

  Widget buildReplyInnerWidget() {
    if (isReply) {
      if (replyChatItem != null) {
        return Column(
          children: [
            ItemGroupChatReplyInnerWidget(
                key: ValueKey(replyChatItem!.messageId),
                isCurrentUser: replyChatItem!.direction == 1,
                item: replyChatItem!
            ),
            SizedBox(
              height: ScreenUtil().setWidth(12),
            )
          ],
        );
      }
      return Column(
        children: [
          ReplyEmptyWidget(),
          SizedBox(
            height: ScreenUtil().setWidth(12),
          )
        ],
      );
    }
    return const SizedBox();

  }



  Widget buildMessageStatus() {
    if (widget.isCurrentUser) {
      if (_item.status == 0) {
        return SizedBox(
            width: ScreenUtil().setWidth(24),
            height: ScreenUtil().setWidth(24),
            child: CircularProgressIndicator(
              color:
              AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
            ));
      } else if (_item.status == -1) {
        return Icon(
          Icons.warning_amber_rounded,
          color: Colors.redAccent,
          size: ScreenUtil().setWidth(40),
        );
      }
      return const SizedBox();
    }
    return const SizedBox();
  }

  //1 = text 、2= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  Widget _buildDefaultIcon() {
    if (messageType == 1) {
      return const Icon(
        Icons.text_fields,
        color: Colors.white,
      );
    }

    if (messageType == 3) {
      return const Icon(
        Icons.image,
        color: Colors.white,
      );
    }
    if (messageType == 10) {
      return Image.asset("assets/chat/money2.png",color: Colors.white,width: ScreenUtil().setWidth(48),height: ScreenUtil().setWidth(48),);
    }
    return const Icon(
      Icons.file_copy_outlined,
      color: Colors.white,
    );
  }

  @override
  bool get wantKeepAlive => true;
}