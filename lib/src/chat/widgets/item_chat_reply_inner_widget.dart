import 'dart:io';
import 'dart:typed_data';

import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/widgets/file_aes_crypt_utils.dart';
import 'package:n42appv2/src/chat/widgets/file_utils.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/widgets/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///嵌入到消息item的内部回复消息
class ItemChatReplyInnerWidget extends StatefulWidget {
  final bool isCurrentUser;
  final ChatMessageModel item;
  final String? userName;

  const ItemChatReplyInnerWidget(
      {super.key,
        required this.isCurrentUser,
        required this.item,
        this.userName});

  @override
  State<ItemChatReplyInnerWidget> createState() =>
      _ItemChatReplyInnerWidgetState();
}

class _ItemChatReplyInnerWidgetState extends State<ItemChatReplyInnerWidget>
    with AutomaticKeepAliveClientMixin {
  ChatDBApi? _chatDBUtils;
  ChatDBApi get chatDBUtils{
    _chatDBUtils ??= ChatDBApi();
    return _chatDBUtils!;
  }
  ChatUtil? _chatUtils;
  ChatUtil get chatUtils{
    _chatUtils ??= ChatUtil();
    return _chatUtils!;
  }
  FileUtils? _fileUtils;
  FileUtils get fileUtils{
    _fileUtils ??= FileUtils();
    return _fileUtils!;
  }
  late ChatMessageModel _item;

  //1 = text 、6= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  int messageType = 0;

  // 消息是否已经解析成功
  String? content = "";
  Uint8List? uint8list;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    messageType = _item.content.type;
    handlerMessage();
  }

  handlerMessage() async {
    try {
      if (messageType == 1) {
        //文本消息
        if (_item.decryptionMessageContent != null) {
          //已经解密
          content = _item.decryptionMessageContent;
        } else {
          // debugPrint("111111111");
          try {
            final encyMessage = _item.content.searchableContent;
            debugPrint("encyMessage ： $encyMessage");
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

            await chatDBUtils.updateMessage(_item);

            setState(() {});
          } catch (_) {
            // 文本消息解密失败时安全忽略，显示默认图标
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

          String savePath = await fileUtils.getTempDirByName(fileName);
          //File openFile = File(openFilepath);


          ///Perform file download
          ///// https://ipfs.infura.io/ipfs/QmVEbHPksyCcTGNajMm8QThSiB9AvSWpYGCssnhnKuzwtY 图片
          //FileApi fileApi=FileApi();
          final fileData = await IpfsApi().downLoadFile(fileUrl, savePath,
              receiveProgress: (int count, int total) {
                // debugPrint("file count: $count  total:$total");
              });
          debugPrint("file response data: $fileData");

          if (fileData) {
            ///2、After successful download, use the private key to decrypt the secret text to obtain the password
            String password = await decryptionCode();
            if (password.isEmpty) {

              return;
            }

            final newPath =
            await FileAesCryptUtils().isolateDecryptFile(savePath, password);

            if (newPath != null) {
              content = newPath;

              //更新数据库、内存
              widget.item.decryptionMessageContent = content;
              _item.decryptionMessageContent = content;
              chatDBUtils.updateMessage(_item);

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
      setState(() {});
    } catch (_) {
      // 消息处理过程中的错误安全忽略，显示默认图标
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
    // Use IChatCryptoService instead of WalletActionProvider
    final cryptoService = ServiceLocatorSetup.chatCryptoService;
    Map<String, String> keyMap = {};
    if (cryptoService != null) {
      keyMap = await cryptoService.getPublicKeyAndPrivateKeyPairs();
    }
    final privateKey = keyMap["$mPubKey"];

    //这里使用查询出的私钥
    final decode = await chatUtils.chatDecode(
        privateKey ?? '', Base64Utils().decodeBase64(cipherText));
    String password = DataUtils().toStringFromHex(decode ?? '');
    return password;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Expanded(
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemBgColor.name),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil().setWidth(4)),
                      topRight: Radius.circular(ScreenUtil().setWidth(16)),
                      bottomLeft: Radius.circular(ScreenUtil().setWidth(4)),
                      bottomRight: Radius.circular(ScreenUtil().setWidth(16)),
                    )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //因为父节点：被IntrinsicHeight包裹，这里Container会自动填充到最大高度
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xff104B9E),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(ScreenUtil().setWidth(4)),
                              bottomLeft: Radius.circular(ScreenUtil().setWidth(4)))),
                      width: 4,
                    ),
                    // const SizedBox(
                    //   width: 6,
                    // ),
                    Expanded(child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(14),vertical: ScreenUtil().setWidth(14)),
                      child: _buildMessageView(),
                    ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildMessageView() {
    if (content != null && content!.isNotEmpty) {
      if (messageType == 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(12),
            ),
            Text(
              content ?? '',
              maxLines: 5,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              overflow: TextOverflow.ellipsis,
            )
          ],
        );
      }

      //图片
      if (messageType == 3) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(12),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              child: Image.file(
                File(content!),
                width: ScreenUtil().setWidth(120),
                height: ScreenUtil().setWidth(100),
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      }

      //视频
      if (messageType == 6) {
        // video
        if (uint8list != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(32),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(12),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                child: SizedBox(
                  width: ScreenUtil().setWidth(120),
                  height: ScreenUtil().setWidth(100),
                  child: Stack(
                    children: [
                      Image.memory(
                        uint8list!,
                        height: ScreenUtil().setWidth(100),
                        fit: BoxFit.cover,
                      ),
                      Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.blueAccent,
                            size: ScreenUtil().setWidth(48),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      }

      //其他类型的文件
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.userName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(12),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FileIcon(
                // widget.item.file_name ?? '',
                content!,
                size: ScreenUtil().setWidth(48),
                iconColor: Colors.black87,
              ),
              Text(
                fileUtils.getFileNameByPath(content!),
                overflow: TextOverflow.visible,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(20)),
              )
            ],
          ),
        ],
      );
    }

    //消息未解析成功时 显示默认图标
    return _buildDefaultIcon();
  }

  //1 = text 、6= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  _buildDefaultIcon() {
    if (messageType == 1) {
      return const Icon(
        Icons.text_fields,
        color: Colors.grey,
      );
    }

    if (messageType == 3) {
      return const Icon(
        Icons.image,
        color: Colors.grey,
      );
    }
    return const Icon(
      Icons.file_copy_outlined,
      color: Colors.grey,
    );
  }

  @override
  bool get wantKeepAlive => true;
}