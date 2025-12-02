import 'dart:io';
import 'dart:typed_data';

import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_compress/video_compress.dart';

class BottomInputChatReplyWidget extends StatefulWidget {
  final ChatMessageModel item;
  final GestureTapCallback? onCloseTap;
  final String? friendName;

  const BottomInputChatReplyWidget(
      {super.key, this.onCloseTap, required this.item, this.friendName});

  @override
  State<BottomInputChatReplyWidget> createState() => _BottomInputChatReplyWidgetState();
}

class _BottomInputChatReplyWidgetState extends State<BottomInputChatReplyWidget> {
  late ChatMessageModel _item;

  //1 = text 、6= video、3= image、Location = 4   File = 5  Tip_Notification = 90 提示文本
  int messageType = 0;

  // 消息是否已经解析成功
  String? content = "";
  Uint8List? uint8list;

  @override
  void initState() {
    super.initState();
    handlerMessage();
  }

  handlerMessage() async {
    try {
      _item = widget.item;
      messageType = _item.content.type;
      //消息必须已经解密才可以回复 所以这里可以不用再次解析了
      content = _item.decryptionMessageContent;
      if (messageType == 6) {
        //video first layer
        uint8list = await VideoCompress.getByteThumbnail(
            content!,
            quality: 60, // default(100)
            position: -1 // default(-1)
        );
        /*uint8list = await video_compress.thumbnailData(
          video: content!,
          imageFormat: ImageFormat.PNG,
          maxWidth: 128,
          quality: 60,
        );*/
      }
      setState(() {});
    } catch (err) {
      //err
    }
  }


  @override
  void didUpdateWidget( BottomInputChatReplyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    handlerMessage();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(28)),
        color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff1E1E1E) :const  Color(0xfff6f6f6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil().setWidth(4)),
                      topRight: Radius.circular(ScreenUtil().setWidth(16)),
                      bottomLeft: Radius.circular(ScreenUtil().setWidth(4)),
                      bottomRight: Radius.circular(ScreenUtil().setWidth(16)),
                    ),
                    // color: Color(0xffffffff),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor3.name),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ScreenUtil().setWidth(4)),
                                bottomLeft: Radius.circular(ScreenUtil().setWidth(4)))),
                        width: 4,
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(12),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(22)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.friendName ?? '',
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
                                    _buildMessage()
                                  ],
                                ),
                              ),
                            ),
                            // 如果是 文件或者 图片展示
                            _buildFileIcon(),
                            SizedBox(width: ScreenUtil().setWidth(12),)
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            SizedBox(
              width: ScreenUtil().setWidth(14),
            ),
            GestureDetector(
              onTap: widget.onCloseTap,
              child: const Icon(
                Icons.close,
                color: Color(0xff9599A0),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildMessage() {
    if (messageType == 1) {
      return Text(
        content ?? '',
        maxLines: 2,
        style: TextStyle(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(32),
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
    if (messageType == 3) {
      return Text(
        "[Image]",
        maxLines: 1,
        style: TextStyle(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(32),
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (messageType == 6) {
      return Text(
        "[video]",
        maxLines: 1,
        style: TextStyle(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(32),
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      "[File]",
      maxLines: 1,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: ScreenUtil().setSp(32),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  _buildFileIcon() {
    if(content != null){
      if (messageType == 1) {
        return const SizedBox();
      }
      if (messageType == 3) {
        return Image.file(
          File(content!),
          width: ScreenUtil().setWidth(90),
          height: ScreenUtil().setWidth(90),
          fit: BoxFit.cover,
        );
      }

      if (messageType == 6) {
        return uint8list != null ? Image.memory(
          uint8list!,
          width: ScreenUtil().setWidth(90),
          height: ScreenUtil().setWidth(90),
          fit: BoxFit.cover,
        ) : const SizedBox();
      }

      return FileIcon(
        content!,
        size: ScreenUtil().setWidth(90),
      );
    }

    return const SizedBox();
  }
}