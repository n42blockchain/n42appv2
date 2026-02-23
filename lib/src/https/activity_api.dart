import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/https/base_api.dart';
import 'package:n42_wallet/src/models/message_model.dart';

class ActivityApi {
  late String url;
  late Map<String,String> header;
  ActivityApi(){
    url=AppConfig.getApiUrlOnline('activiteHost');
    header={'content-type': 'application/json'};
  }
  //数据收集接口，发送推送
  Future<MessageModel> collectDelayPush(String nftData,{String event="create_nft"}) async {
    try {
      MessageModel mm = MessageModel();
      Map<String, dynamic> postData = {
        "event": event,
        "data": nftData,
      };
      final data = await BaseApi.requestEmptyH
          .post('$url/w/collect/delay/push', params: {}, data: postData,header: header,);
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'];
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
  //数据收集接口，修改 用户创建的NFT
  Future<MessageModel> collectPushUpdate(Map<String, dynamic> nftData) async{
    try {
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH
          .post('$url/w/collect/update', params: {}, data: nftData,header: header,);
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'];
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}