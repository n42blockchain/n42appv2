import 'dart:convert';

import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:path/path.dart' as path;

class ChatUploadFile{
  static Future handlerFile(String targetUuid,dynamic newPath,ChatMessageModel cm,Map<String, dynamic> content) async {
    final data = await upLoadFile(newPath);
    //await compute(upLoadFile, newPath);
    //{Hash: bafybeieufukwa6vqh3je7wkh4kx54mdmyfqjujba3k4xaapso6crz6ujii,
    // Name: u=1503362238,2089207733&fm=253&fmt=auto&app=120&f=JPEG.webp.aes,
    // Size: 16894}
    if (data['error'] == false) {
      final fileName = data['data']['Name'];
      //final fileSize = data['Size'];
      //FileApi fileApi=FileApi();
      final fileServerUrl = "${AppConfig.apiUrl['ipfsAddress']}${data['data']['Hash']}";
      //fileApi.generateUrl(data['data']['Hash'], fileName);
      //发送消息到服务器
      cm.content.searchableContent = fileServerUrl;
      ChatDBApi chatDBApi=ChatDBApi();
      await chatDBApi.saveMessage(cm).then((value) {
      });

      //发送消息去掉 不加密的消息内容 防止抓包数据
      content["decryptionMessageContent"] = null;
      content["content"]["searchableContent"] = fileServerUrl;
      content["content"]["originalFileName"] = fileName;
      ChatApi chatApi=ChatApi();
      try {
        final data = await chatApi.sendMessage(
          fromUUID: Application.userInfo?.uuid ?? '',
          receiveId: targetUuid,
          content: json.encode(content),
        );

        if (data != null && data["code"] == 200) {
          chatDBApi.updateMessage(cm).then((value) {
          });
          MessageModel mm=MessageModel();
          mm.data="Message sent successfully!";
          return mm;
          //埋点
          //AmplitudeUtils.sentMessage();
        }
        else {
          chatDBApi.updateMessage(cm).then((value) {
          });
          MessageModel mm=MessageModel.error();
          mm.data="Failed to send message!";
          return mm;
        }
      } catch (err) {
        chatDBApi.updateMessage(cm).then((value) {
        });
        MessageModel mm=MessageModel.error();
        mm.data="Failed to send message!";
        return mm;

      }
    }
    else {
      MessageModel mm=MessageModel.error();
      mm.data="Upload failed!";
      return mm;
    }
  }
  //File upload is encapsulated as a top-level function
  static Future<dynamic> upLoadFile(filePath) async {
    String fileName=path.basename(filePath);
    //上传图片
    Map<String, dynamic> rData = await IpfsApi().uploadIPFSImage(
      filePath,
      fileName,
          (int count, int total) {},
      type: 0,
    );
    return rData;
    /*FileApi fileApi=FileApi();
    final data =
    await fileApi.upLoadFileToIpfs(filePath, (int count, int total) {
      //debugPrint("ipfs:count $count total $total");
    });
    return data;*/
  }
}