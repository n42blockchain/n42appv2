import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_data.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as screen;
import 'package:n42appv2/generated/l10n.dart';

class ItemConversation extends StatefulWidget {
  final ChatMessageModel item;
  final String mPrivateKey;
  final bool isRead;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const ItemConversation(
      {super.key,
        required this.item,
        required this.mPrivateKey,
        this.isRead = true,
        this.onTap,
        this.onLongPress});

  @override
  State<ItemConversation> createState() => _ItemConversationState();
}

class _ItemConversationState extends State<ItemConversation>
    with AutomaticKeepAliveClientMixin {
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
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    _chatDBApi ??= ChatDBApi();
    return _chatDBApi!;
  }
  ChatUtil? _chatUtil;
  ChatUtil get chatUtil{
    _chatUtil ??= ChatUtil();
    return _chatUtil!;
  }
  //1 = text 、6= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  int messageType = 0;

  // Tip_Notification 消息不加密 不需要解析
  // 消息是否已经解析成功
  String? content = "";
  String? image;
  String? name;

  late ChatMessageModel _item;

  bool _isCurrentUser = false;

  bool _isRead = true;

  //是否@了我
  bool isMention = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    _item = widget.item;
    _isRead = widget.isRead;
    messageType = _item.content.type;
    _isCurrentUser = _item.direction == 1;
    content = "";
    isMention = false;
    handlerMentionData();
    updateImageAndName();
    parserMessage();
  }

  handlerMentionData() async {
    //群聊有人@我了
    if (_item.conversationType == 1) {
      isMention = await CacheGroupMentionUtils().isMention(_item.getTargetId());
      //debugPrint("isMention:$isMention");
    }
  }

  @override
  void didUpdateWidget(covariant ItemConversation oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 组件的数据发生改变时 调用
    initData();
  }

  //解析加密消息
  parserMessage() async {
    if (messageType == 90) {
      // 0 单聊 1群组
      if (_item.conversationType == 1) {
        content = _item.content.pushContent2;
      } else {
        content = _item.content.content;
      }
    } else {
      // 其他消息类型需要解密操作
      if (messageType == 1) {
        //文本消息
        if (_item.decryptionMessageContent != null) {
          //已经解密
          content = _item.decryptionMessageContent;
        } else {
          try {
            final encyMessage = _item.content.searchableContent;
            debugPrint("encyMessage ： $encyMessage");

            String? password;

            if (_item.conversationType == 0) {
              //单聊 根据发送消息时携带的pub key 解密出密码
              //解密消息
              String? cipherText;
              if (_isCurrentUser) {
                cipherText = _item.content.senderAesSecret;
              } else {
                cipherText = _item.content.receiverAesSecret;
              }
              debugPrint("cipherText ： $cipherText");
              if (cipherText == null) {
                return;
              }

              //根据发送这条消息时的pub key 找出本地钱包中的private key
              String? mPubKey;
              if (_isCurrentUser) {
                mPubKey = _item.content.senderPubKey;
              } else {
                mPubKey = _item.content.receiverPubKey;
              }
              // Use IChatCryptoService instead of WalletActionProvider
              final cryptoService = ServiceLocatorSetup.chatCryptoService;
              Map<String, String> keyMap = {};
              if (cryptoService != null) {
                keyMap = await cryptoService.getPublicKeyAndPrivateKeyPairs();
              }
              final privateKey = keyMap["$mPubKey"];

              final decode = await chatUtil.chatDecode(
                  privateKey ?? '', Base64Utils().decodeBase64(cipherText));
              password = dataUtils.toStringFromHex(decode ?? '');
              if (password.isEmpty) {
                return;
              }
            } else {
              //群聊根据用户在当前群上传的密文 解密出群消息加密的密码
              // 从缓存取出group pwd
              GroupData? gd =
              await ChatSPUtil().getGroupDataByGroupId(_item.getTargetId());
              if (gd != null) {
                password = gd.groupPwd;
              } else {
                final data =
                await chatApi.checkGroupSSById(_item.getTargetId());
                if (data != null && data['code'] == 200) {
                  final map = data["data"];
                  if (map != null) {
                    final pubKey = map["public_key"];
                    final ss = map["ss"];
                    //兼容多钱包 根据pubKey找出对应钱包的privateKey
                    // Use IChatCryptoService instead of WalletActionProvider
                    final cryptoSvc = ServiceLocatorSetup.chatCryptoService;
                    Map<String, String> keyMap2 = {};
                    if (cryptoSvc != null) {
                      keyMap2 = await cryptoSvc.getPublicKeyAndPrivateKeyPairs();
                    }
                    final privateKey = keyMap2["$pubKey"];
                    if (privateKey == null) {
                      return;
                    }
                    final decode = await chatUtil.chatDecode(
                        privateKey, Base64Utils().decodeBase64(ss));
                    password = dataUtils.toStringFromHex(decode ?? '');
                    //保存group pwd
                    ChatSPUtil().saveGroupDataIfNotExists(
                        GroupData(_item.getTargetId(), password));
                  }
                }
              }
            }

            final messageContent =
            AesUtils().aesDecrypted(encyMessage ?? '', password ?? '');

            content = messageContent;

            //更新数据库、内存
            widget.item.decryptionMessageContent = content;
            _item.decryptionMessageContent = content;

            chatDBApi.updateMessage(_item);

            setState(() {});
          } catch (err) {
            content = "";
          }
        }
      } else {
        //其他文件类型显示 【图片】【视频】【文件】
        //6= video、3= image、Location = 4   File = 5
        if (messageType == 3) {
          content = "[image]";
        } else if (messageType == 6) {
          content = "[video]";
        } else if (messageType == 10) {
          content = "[red pocket]";
        } else {
          content = "[file]";
        }
        setState(() {});
      }
    }
  }

  //更新头像信息
  updateImageAndName() async {
    // 0 单聊 1群组
    if (_item.conversationType == 1) {
      GroupInfo? gi = _item.groupInfo;
      image = gi?.avatar_url;
      name = gi?.name;
    } else {
      FriendInfo? fi = _item.friendInfo;
      image = fi?.image;
      name = //fi?.name;
      (fi?.remarks??"")==""?fi?.name:fi?.remarks??"";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: _buildChatConversationItem(image ?? '', name ?? '', content ?? '',
          onTap: widget.onTap,
          isRead: _isRead,
          onLongPress: widget.onLongPress),
    );
  }

  _buildChatConversationItem(String image, String name, String content,
      {GestureTapCallback? onTap,
        bool isRead = true,
        GestureLongPressCallback? onLongPress}) {
    final bool isToday = DateUtil.isToday(_item.timestamp);
    String timeStr = dataUtils.getTimeByTimeStamp('${_item.timestamp}',
        format: isToday ? "HH:mm" : "dd/MM/yy HH:mm");
    return GestureDetector(
      onTap: onTap,
      // onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: screen.ScreenUtil().setWidth(96),
                  height: screen.ScreenUtil().setWidth(96),
                  //超出部分，可裁剪
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          screen.ScreenUtil().setWidth(100)),
                      border: Border.all(
                          width: 0.5,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemLineColor.name))),
                  child: ImageNetWork(
                    imageUrl: image,
                    width: screen.ScreenUtil().setWidth(48),
                    placeholder: _item.conversationType == 1
                        ? "assets/chat/group_def_icon.png"
                        : "assets/chat/user_def_icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
                if (!isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: screen.ScreenUtil().setWidth(20),
                      height: screen.ScreenUtil().setWidth(20),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                  )
              ],
            ),
            SizedBox(
              width: screen.ScreenUtil().setWidth(32),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name
                  Text(
                    name,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        // fontWeight: FontWeight.bold,
                        fontSize: screen.ScreenUtil().setSp(30)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: screen.ScreenUtil().setWidth(20),
                  ),
                  //email
                  Row(
                    children: [
                      if (isMention)
                        RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: '[',
                                  style: TextStyle(
                                      color: Color(0xFFC1C0C9), fontSize: screen.ScreenUtil().setSp(30))),
                              TextSpan(
                                  text: S.of(context).g_chat_key_68,
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: screen.ScreenUtil().setSp(30))),
                              TextSpan(
                                  text: '] ',
                                  style: TextStyle(
                                      color: Color(0xFFC1C0C9), fontSize: screen.ScreenUtil().setSp(30))),
                            ])),
                      Expanded(
                        child: Text(
                          content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xFFC1C0C9), fontSize: screen.ScreenUtil().setSp(30),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              width: screen.ScreenUtil().setWidth(24),
            ),
            Text(
              timeStr,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.ff888888.name),
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}