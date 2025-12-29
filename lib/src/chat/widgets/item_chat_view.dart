import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/api/file_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_data_util.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/widgets/chat_delete_dialog.dart';
import 'package:n42appv2/src/chat/widgets/file_aes_crypt_utils.dart';
import 'package:n42appv2/src/chat/widgets/file_utils.dart';
import 'package:n42appv2/src/chat/widgets/item_chat_reply_inner_widget.dart';
import 'package:n42appv2/src/chat/widgets/report_widget.dart';
import 'package:n42appv2/src/component/pages/show_image.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/file_icon.dart';
import 'package:n42appv2/src/widgets/reply_empty_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:n42appv2/src/widgets/video_play_safe.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/chat/widgets/report_post.dart';

class ItemChatView extends StatefulWidget {
  final bool isCurrentUser;
  final ChatMessageModel item;
  final String? time;
  final String mPrivateKey;
  final String? friendName;

  //好友信息
  final FriendInfo? info;

  const ItemChatView(
      {Key? key,
        required this.isCurrentUser,
        required this.item,
        this.time,
        required this.mPrivateKey,
        this.info,
        this.friendName})
      : super(key: key);

  @override
  State<ItemChatView> createState() => _ItemChatViewState();
}

class _ItemChatViewState extends State<ItemChatView>
    with AutomaticKeepAliveClientMixin {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    if(_chatApi==null){
      _chatApi=ChatApi();
    }
    return _chatApi!;
  }
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    if(_chatDBApi==null){
      _chatDBApi=ChatDBApi();
    }
    return _chatDBApi!;
  }
  ChatUtil? chatUtils;
  ChatUtil get _chatUtils{
    if(chatUtils==null){
      chatUtils= ChatUtil();
    }
    return chatUtils!;
  }
  FileUtils? fileUtils;
  FileUtils get _fileUtils{
    if(fileUtils==null){
      fileUtils= FileUtils();
    }
    return fileUtils!;
  }

  //1 = text 、6= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  int messageType = 0;

  // Tip_Notification 消息不加密 不需要解析
  // 消息是否已经解析成功
  String? content = "";
  Uint8List? uint8list;

  late ChatMessageModel _item;

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
    _item = widget.item;
    isReply = _item.reply_id != null;
    messageType = _item.content.type;
    handlerMessage();
  }

  findReplyMessage() async {
    try {
      if (isReply) {
        replyChatItem =
        await chatDBApi.getMessageByMessageId(_item.reply_id!);
      }
    } catch (err) {
    }
  }

  handlerMessage() async {
    try {
      isLoading = true;

      //先查找回复的消息
      await findReplyMessage();

      if (messageType == 90) {
        // 0 单聊 1群组
        if (_item.conversationType == 1) {
          ChatDataUtil chatDataUtils=ChatDataUtil();
          _item.content.pushContent2 = await chatDataUtils.generateGroupTips(
              json.decode(_item.content.pushContent ?? ''));
          content = _item.content.pushContent2;
        } else {
          content = _item.content.content;
        }
        setState(() {});
      } else {
        // 其他消息类型需要解密操作
        if (messageType == 1) {
          //文本消息
          if (_item.decryptionMessageContent != null) {
            //已经解密
            content = _item.decryptionMessageContent;
            setState(() {});
          } else {
            try {
              final encyMessage = _item.content.searchableContent;
              String password = await decryptionCode();
              if (password.isEmpty) {

                return;
              }
              final messageContent =
              AesUtils().aesDecrypted(encyMessage ?? '', password);

              content = messageContent;

              //更新数据库、内存
              widget.item.decryptionMessageContent = content;
              _item.decryptionMessageContent = content;

              await chatDBApi.updateMessage(_item);

              setState(() {});
            } catch (err) {
            }
          }
        } else {
          //image、video、file、
          // debugPrint("--本地文件路径 - >>> :${_item.decryptionMessageContent}");
          String? filePath = _item.decryptionMessageContent;
          if (filePath != null) {
            //如果数据库中保存的路径文件 已经删除 则需要重新下载更新
            if (!await File(filePath).exists()) {
              _item.decryptionMessageContent = null;
            } else {
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
            if (fileName == null || fileUrl == null) return;
            String savePath = await _fileUtils.getTempDirByName(fileName);
            debugPrint("savePath : $savePath");
            String openFileName =
            fileName.substring(0, fileName.lastIndexOf('.'));
            String openFilepath =
            await _fileUtils.getTempDirByName(openFileName);
            //File openFile = File(openFilepath);


            ///Perform file download
            ///// https://ipfs.infura.io/ipfs/QmVEbHPksyCcTGNajMm8QThSiB9AvSWpYGCssnhnKuzwtY 图片
            //FileApi fileApi=FileApi();
            final fileData = await IpfsApi().downLoadFile(fileUrl, savePath,
                receiveProgress: (int count, int total) {
                });

            if (fileData) {
              ///2、After successful download, use the private key to decrypt the secret text to obtain the password
              String password = await decryptionCode();
              if (password.isEmpty) {
                return;
              }

              final newPath = await FileAesCryptUtils().isolateDecryptFile(
                  savePath, password);
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
              }
            }
          }
        }
      }
    } finally {
      isLoading = false;
    }
  }

  Future<String> decryptionCode() async {
    //解密消息
    String? cipherText;
    if (widget.isCurrentUser) {
      cipherText = _item.content.senderAesSecret;
    } else {
      cipherText = _item.content.receiverAesSecret;
    }
    if (cipherText == null) {
      return "";
    }

    //根据发送这条消息时的pub key 找出本地钱包中的private key
    String? mPubKey;
    if (widget.isCurrentUser) {
      mPubKey = _item.content.senderPubKey;
    } else {
      mPubKey = _item.content.receiverPubKey;
    }
    Map<String,String> keyMap =await Provider.of<WalletActionProvider>(context,listen: false).publicKeyAndPrivateKeyPair();
    final privateKey = keyMap["$mPubKey"];

    // final decode = await ChatUtils.chatDecode(
    //     widget.mPrivateKey ?? '', Base64Utils.decodeBase64(cipherText));
    //这里使用查询出的私钥
    final decode = await _chatUtils.chatDecode(
        privateKey ?? '', Base64Utils().decodeBase64(cipherText));

    String password = DataUtils().toStringFromHex(decode ?? '');
    return password;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        if (widget.time != null)
          Container(
            margin: EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(12), horizontal:  ScreenUtil().setWidth(24)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular( ScreenUtil().setWidth(32)),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(12), horizontal:  ScreenUtil().setWidth(12)),
                child: Text(
                  widget.time!,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize:  ScreenUtil().setSp(24)),
                ),
              ),
            ),
          ),

        //渲染提示文本
        if (messageType == 90)
          Container(
            margin: EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(12), horizontal:  ScreenUtil().setWidth(48)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // color: AppThemeUtils.getColorByKey(
                //     context, AppThemeKeys.mainBoxColor),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular( ScreenUtil().setWidth(32)),
              ),
              child: Container(
                padding:
                EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(24), horizontal:  ScreenUtil().setWidth(24)),
                child: Text(
                  content ?? '',
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize:  ScreenUtil().setSp(24)),
                ),
              ),
            ),
          ),
        if (messageType != 90)
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.isCurrentUser ?  ScreenUtil().setWidth(128) :  ScreenUtil().setWidth(32),
              ScreenUtil().setWidth(24),
              widget.isCurrentUser ?  ScreenUtil().setWidth(32) :  ScreenUtil().setWidth(128),
              ScreenUtil().setWidth(12),
            ),
            child: Align(
              // align the child within the container
              alignment: widget.isCurrentUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: CustomPopupMenu(
                  verticalMargin: 6,
                  pressType: PressType.longPress,
                  controller: controller,
                  arrowColor: Colors.white,
                  child: GestureDetector(
                    onTap: () async {
                      // 解析消息失败时 点击继续解析消息todo
                      if (content != null && messageType != 0) {
                        try {
                          if (messageType == 3) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ShowImage(" ", File(content!),
                                    type: "file",watermark:"")));
                          }else if(messageType==6){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPlaySafe(content!,dataType: "local",)));
                          }
                          else {
                            OpenFilex.open(content!);
                          }
                        } catch (err) {
                        }
                      }
                      if (content == null) {
                        if (!isLoading) {
                          ToastUtils.show("decryption failure");
                          handlerMessage();
                        }
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: _buildItem(context),
                    ),
                  ),
                  menuBuilder: () {
                    return IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular( ScreenUtil().setWidth(40)),
                          color: const Color(0xffFEFEFE),
                        ),
                        width:  ScreenUtil().setWidth(500),
                        child: Column(
                          children: [
                            //消息回复
                            if (content != null)
                              GestureDetector(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:  ScreenUtil().setWidth(24), horizontal:  ScreenUtil().setWidth(36)),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Text(S.of(context).g_chat_key_66,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:  ScreenUtil().setSp(32))),
                                            const Spacer(),
                                            Image.asset(
                                                "assets/chat/huifu.png",
                                                width:  ScreenUtil().setWidth(48),
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
                                  FriendInfo? info =
                                  await ChatSPUtil().getNavUserInfo(
                                      _item.getTargetId());
                                  //底部弹出举报框
                                  SheetBottom(
                                    context,
                                    "",
                                    ReportWidget(
                                      name: info?.name ?? '',
                                      reportAndBlockCallBack: () {
                                        Navigator.of(context).pop();
                                        final controller =
                                        TextEditingController();
                                        //底部弹出举报框
                                        SheetBottom(
                                            context,
                                            isDismissible: false,
                                            "",
                                            ReportPost(
                                              name: info?.name ?? '',
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
                                                    _item.content.reportType =
                                                    1;
                                                    chatDBApi.updateMessage(
                                                        _item);
                                                    setState(() {
                                                      showReportMessage = false;
                                                    });
                                                    //举报成功之后拉黑用户
                                                    final blockUser =
                                                    await chatApi
                                                        .blockFriend(
                                                        _item.targetId);
                                                  }
                                                } finally {
                                                }
                                              },
                                              controller: controller,
                                            ));
                                      },
                                      reportCallBack: () {
                                        Navigator.of(context).pop();
                                        final controller =
                                        TextEditingController();
                                        //底部弹出举报框
                                        SheetBottom(
                                            context,
                                            isDismissible: false,
                                            "",
                                            ReportPost(
                                              name: info?.name ?? '',
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
                                                    _item.content.reportType =
                                                    1;
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
                                      vertical:  ScreenUtil().setWidth(24), horizontal:  ScreenUtil().setWidth(36)),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        Text(
                                          S.of(context).g_chat_key_40,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:  ScreenUtil().setSp(32)),
                                        ),
                                        const Spacer(),
                                        Image.asset("assets/chat/flag.png",
                                            width:  ScreenUtil().setWidth(48), fit: BoxFit.cover)
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
                                          vertical:  ScreenUtil().setWidth(24), horizontal:  ScreenUtil().setWidth(36)),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Text(S.of(context).g_key_119,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:  ScreenUtil().setWidth(32))),
                                            const Spacer(),
                                            Image.asset(
                                                "assets/chat/content_copy.png",
                                                width:  ScreenUtil().setWidth(48),
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
                                    vertical:  ScreenUtil().setWidth(24), horizontal:  ScreenUtil().setWidth(36)),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Text(S.of(context).g_key_113,
                                          style: TextStyle(
                                              color: Color(0xffFE3B30),
                                              fontSize:  ScreenUtil().setSp(32))),
                                      const Spacer(),
                                      Image.asset("assets/chat/delete.png",
                                          width:  ScreenUtil().setWidth(48), fit: BoxFit.cover)
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () async {
                                controller.hideMenu();
                                SheetBottom(context, "", ChatDeleteDialog(
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
                  }),
              // child: _buildItem(context),
            ),
          ),
      ],
    );
  }

  _buildItem(BuildContext context) {
    BorderRadiusGeometry? _borderRadius = widget.isCurrentUser
        ? BorderRadius.only(
        topLeft: Radius.circular( ScreenUtil().setWidth(16)),
        topRight: Radius.circular( ScreenUtil().setWidth(16)),
        bottomLeft: Radius.circular( ScreenUtil().setWidth(16)),
        bottomRight: Radius.circular( ScreenUtil().setWidth(4)))
        : BorderRadius.only(
        topLeft: Radius.circular( ScreenUtil().setWidth(16)),
        topRight: Radius.circular( ScreenUtil().setWidth(16)),
        bottomLeft: Radius.circular( ScreenUtil().setWidth(16)),
        bottomRight: Radius.circular( ScreenUtil().setWidth(16)));

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
                  borderRadius: _borderRadius,
                ),
                child: Padding(
                    padding: EdgeInsets.all( ScreenUtil().setWidth(24)),
                    child: Text(
                      S.of(context).g_chat_key_57,
                      style: TextStyle(
                        color: widget.isCurrentUser ? Colors.white : Colors.black87,
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
                    borderRadius: _borderRadius,
                  ),
                  child: Padding(
                      padding: EdgeInsets.all( ScreenUtil().setWidth(24)),
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
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      )),),
              ),
            ],
          ),
        );
      } else if (messageType == 3) {
        //image 类型
        return IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildMessageStatus(),
              ClipRRect(
                borderRadius: BorderRadius.circular( ScreenUtil().setWidth(16)),
                child: Container(
                    width:  ScreenUtil().setWidth(180),
                    height:  ScreenUtil().setWidth(160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( ScreenUtil().setWidth(16)),
                    ),
                    alignment: Alignment.center,
                    child: Image.file(
                      File(content!),
                      width:  ScreenUtil().setWidth(180),
                      height:  ScreenUtil().setWidth(160),
                      fit: BoxFit.cover,
                    )),
              )
            ],
          ),
        );
      } else if (messageType == 6) {
        // video
        if (uint8list != null) {
          return IntrinsicWidth(
            child: Row(
              children: [
                buildMessageStatus(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width:  ScreenUtil().setWidth(180),
                    height:  ScreenUtil().setWidth(160),
                    child: Stack(
                      children: [
                        Image.memory(
                          uint8list!,
                          width:  ScreenUtil().setWidth(180),
                          height:  ScreenUtil().setWidth(160),
                          fit: BoxFit.cover,
                        ),
                        Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.blueAccent,
                              size:  ScreenUtil().setWidth(72),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        return IntrinsicWidth(
          child: Row(
            children: [
              buildMessageStatus(),
              Container(
                width:  ScreenUtil().setWidth(180),
                padding:
                EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(24), horizontal:  ScreenUtil().setWidth(16)),
                decoration: BoxDecoration(
                  color: widget.isCurrentUser ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular( ScreenUtil().setWidth(16)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FileIcon(
                      // widget.item.file_name ?? '',
                      content!,
                      size:  ScreenUtil().setWidth(48),
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
                          fontSize:  ScreenUtil().setSp(20)),
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
        height:  ScreenUtil().setWidth(120),
        width:  ScreenUtil().setWidth(180),
        decoration: BoxDecoration(
          color: widget.isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular( ScreenUtil().setWidth(16)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDefaultIcon(),
          ],
        ));
  }

  ///构建回复消息
  buildReplyInnerWidget() {
    if (isReply) {
      if (replyChatItem != null) {
        return Column(
          children: [
            ItemChatReplyInnerWidget(
                key: ValueKey(replyChatItem!.messageId),
                isCurrentUser: replyChatItem!.direction == 1,
                item: replyChatItem!,
                userName: replyChatItem!.direction == 1
                    ? AppGlobals.userInfo?.name
                    : widget.friendName),
            const SizedBox(
              height: 6,
            )
          ],
        );
      }
      return Column(
        children: [
          ReplyEmptyWidget(),
          SizedBox(
            height:  ScreenUtil().setWidth(12),
          )
        ],
      );
    }
    return const SizedBox();
  }

  buildMessageStatus() {
    if (widget.isCurrentUser) {
      if (_item.status == 0) {
        return SizedBox(
            width:  ScreenUtil().setWidth(24),
            height:  ScreenUtil().setWidth(24),
            child: CircularProgressIndicator(
              color:
              AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
            ));
      } else if (_item.status == -1) {
        return Icon(
          Icons.warning_amber_rounded,
          color: Colors.redAccent,
          size:  ScreenUtil().setWidth(40),
        );
      }
      return const SizedBox();
    }
    return const SizedBox();
  }

  //1 = text 、6= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  _buildDefaultIcon() {
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
    return const Icon(
      Icons.file_copy_outlined,
      color: Colors.white,
    );
  }

  @override
  bool get wantKeepAlive => true;
}