import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class ActivityApi {
  late String url;
  late Map<String,String> header;
  ActivityApi(){
    url=AppConfig.getApiUrl_online('activiteHost');
    header={'content-type': 'application/json'};
  }
  //数据收集接口，收集用户创建的NFT和交易AST的记录，event create_nft,wallet_transfer
  collectPush(String nftData,{String event="create_nft"}) async {
    try {
      MessageModel mm = MessageModel();
      Map<String, dynamic> postData = {
        "event": event,
        "data": nftData,
      };
      final data = await BaseApi.RequestEmpty_h
          .post('$url/w/collect/push', params: {}, data: postData,header: header,);
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
  //数据收集接口，发送推送
  collectDelayPush(String nftData,{String event="create_nft"}) async {
    try {
      MessageModel mm = MessageModel();
      Map<String, dynamic> postData = {
        "event": event,
        "data": nftData,
      };
      final data = await BaseApi.RequestEmpty_h
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
  collectPush_update(Map<String, dynamic> nftData)async{
    try {
      MessageModel mm = MessageModel();
      final data = await BaseApi.RequestEmpty_h
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
/*
  //获取快捷Tab 列表
  static getShortcutList() async {
    try {
      MessageModel mm = MessageModel();
      final data =
          await Api.nftActivity.get('/activity/shortcut/list', params: {});
      if (data['code'] == 200) {
        mm.data = data;
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

  //点赞活动报名
  static likeEnroll(int actionId) async {
    try {
      String uuid = AppGlobals.userInfo!.uuid;
      MessageModel mm = MessageModel();
      Map<String, dynamic> postData = {"activityId": actionId, "userId": uuid};
      final data = await Api.nftActivity
          .post('/activity/ntf/like/enroll', params: {}, data: postData);
      int code = data['code'];
      if (code == 200) {
        mm.data = true;
      } else if (code == 2006) {
        //已经报名
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

  //查询点赞活动是否报名
  static enrollStatus(int actionId) async {
    try {
      String uuid = AppGlobals.userInfo!.uuid;
      MessageModel mm = MessageModel();
      final data = await Api.nftActivity.get(
          '/activity/enroll/status?activity_id=${actionId}&user_id=${uuid}',
          params: {});
      if (data['code'] == 200) {
        mm.data = data['data'];
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

  //激活/取消激活 参赛nft
  static activateStatus(actionId) async {
    try {
      String uuid = AppGlobals.userInfo!.uuid;
      MessageModel mm = MessageModel();
      Map<String, dynamic> postData = {
        "activity_nft_like_list_id": actionId,
        "user_id": uuid
      };
      final data = await Api.nftActivity
          .post('/activity/nft/activate/status', params: {}, data: postData);
      int code = data['code'];
      if (code == 200) {
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

  //点赞，取消点赞
  static nftLike(int itemId) async {
    try {
      String uuid = AppGlobals.userInfo!.uuid;
      MessageModel mm = MessageModel();
      Map<String, dynamic> postData = {
        "activityNFTLikeListId": itemId,
        "userId": uuid
      };
      final data = await Api.nftActivity
          .post('/activity/nft/like', params: {}, data: postData);
      int code = data['code'];
      if (code == 200) {
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

  //获取点赞nft列表,type=0全部nft数据，1，当前用户的nft数据;activite：1激活nft 2 未激活nft
  static getLikeItemList(int activityId, int page, int pageSize, int type,
      {int activite = 0}) async {
    try {
      String uuid = "";
      if (type == 1) {
        uuid = '&user_id=' + AppGlobals.userInfo!.uuid;
      }
      if (activite != 0) {
        uuid += '&activate=' + activite.toString();
      }
      MessageModel mm = MessageModel();
      final data = await Api.nftActivity.get(
        '/activity/item/list?activity_id=${activityId}&sort_by=-like_num,-created&page=${page}&page_size=${pageSize}' +
            uuid,
        params: {},
      );
      if (data['code'] == 200) {
        mm.data = data;
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
  */
}