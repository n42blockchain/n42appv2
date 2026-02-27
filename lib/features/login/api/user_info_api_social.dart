part of 'user_info_api.dart';

/// UserInfoApi 第三方登录、邀请、支付、消息、反馈相关扩展
extension UserInfoApiSocial on UserInfoApi {
  /// 第三方登录 - Google
  /// idToken: Google ID Token
  /// accessToken: Google Access Token (optional)
  Future<dynamic> loginWithGoogle(String idToken, {String? accessToken, Map<String, dynamic>? deviceInfo}) async {
    Map<String, dynamic> params = {
      "provider": "google",
      "id_token": idToken,
      "source": "app",
    };
    if (accessToken != null) {
      params["access_token"] = accessToken;
    }
    if (deviceInfo != null) {
      params.addAll(deviceInfo);
    }
    final data = await BaseApi.requestEmptyH.post(
      '$url/v1/user/loginSocial',
      params: {},
      data: params,
      header: header,
    );
    return data;
  }

  /// 第三方登录 - Apple
  /// idToken: Apple Identity Token
  /// authorizationCode: Apple Authorization Code
  Future<dynamic> loginWithApple(
    String idToken,
    String authorizationCode, {
    String? rawNonce,
    Map<String, dynamic>? deviceInfo,
  }) async {
    Map<String, dynamic> params = {
      "provider": "apple",
      "id_token": idToken,
      "authorization_code": authorizationCode,
      "source": "app",
      "nonce": ?rawNonce,
    };
    if (deviceInfo != null) {
      params.addAll(deviceInfo);
    }
    final data = await BaseApi.requestEmptyH.post(
      '$url/v1/user/loginSocial',
      params: {},
      data: params,
      header: header,
    );
    return data;
  }

  ///FCM推送绑定设备 token
  Future bindPushUserToken(String pushToken, {String? deviceId}) async {
    Map<String, dynamic> params = {};
    params["firebase_token"] = pushToken;
    params["uuid"] = AppGlobals.userInfo?.uuid??"";
    params["token"] = AppGlobals.userInfo?.token??"";
    params["source"] = "app";
    if (deviceId != null) {
      params["device_id"] = deviceId;
    }
    final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/file/bind/firebase/token',
        params: {},
        data: params,header: header
    );
    return data;
  }

  //获取邀请人code
  Future getInviterCode(
      String mobileModel, String mobileName, String os) async {
    Map<String, dynamic> params = {};
    params["mobile_model"] = mobileModel;
    params["mobile_name"] = mobileName;
    params["os"] = os;
    final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/user/inviter/code',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data['data'];
    }
    return null;
  }
  //获取邀请用户，挖矿收益
  Future getInviteeMiningInfo(String uuid)async{
    Map<String, dynamic> params = {
      "uuid": uuid,
    };
    final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/user/invitee/mining/fullnode',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  Future getInviteeMiningCount(String uuid)async{
    Map<String, dynamic> params = {
      "uuid": uuid,
    };
    final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/user/invitee/mining',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  //获取邀请用户，下载app的数量
  Future getInviteeDownloadList(String uuid,
      {int pagenum= 1, int pagesize= 1}) async {
    Map<String, dynamic> params = {
      "uuid": uuid,
      "page_size": pagesize,
      "page_num": pagenum,
    };
    final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/user/invitee/list/download',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  //获取用户邀请的人数
  Future getInviteeList(String uuid) async {
    Map<String, dynamic> params = {};
    params["uuid"] = uuid;
    final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/user/invitee/list',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  //提交反馈信息,address钱包地址，content反馈内容，extra附件地址
  Future<MessageModel> submitFeedback(String address,String content,String extra)async{
    try{
      String token=AppGlobals.userInfo?.token??"";
      String uuid=AppGlobals.userInfo?.uuid??"";
      MessageModel mm=MessageModel();
      Map<String,dynamic> dt={
        "uuid": uuid,
        "source": "app",
        "token": token,
        "wallet_addr":address,
        "content": content,
        "extra":extra,
      };

      mm.data=await BaseApi.requestEmptyH.post('$url/v1/l/feedback',params: {},data:dt ,header: header,addUserInfo: true);
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //获取 消息列表
  Future<MessageModel> getMsgNoticeList({int page=1,int pageSize=10,String msgType=""})async{
    try {
      MessageModel mm = MessageModel();
      final data =
      await BaseApi.requestEmptyH.get('$url/v1/lr/get/msg/notice/list', params: {
        "uuid":AppGlobals.userInfo?.uuid??"",
        "page":page,
        "page_size":pageSize,
        "msg_type":msgType,
        "token":AppGlobals.userInfo?.token??"",
        "source":"app"
      },header: header);
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

  /// 发送收款通知（支付方调用，通知收款方「确认收款」推送）
  /// [toUuid]       收款方用户 UUID
  /// [txHash]       链上交易哈希
  /// [amount]       法币金额（如 "9.9"）
  /// [tokenAmount]  代币金额（如 "10.1 USDT"）
  /// [coinType]     链类型（如 "ETH"、"BSC"）
  /// [tokenName]    代币名称（如 "USDT"）
  Future<MessageModel> sendPaymentReceipt({
    required String toUuid,
    required String txHash,
    required String amount,
    required String tokenAmount,
    required String coinType,
    required String tokenName,
  }) async {
    try {
      // 构建请求体，跳过空字符串字段以减小 payload 体积
      final Map<String, dynamic> params = {
        "uuid"      : AppGlobals.userInfo?.uuid ?? "",
        "token"     : AppGlobals.userInfo?.token ?? "",
        "source"    : "app",
        "to_uuid"   : toUuid,
        "tx_hash"   : txHash,
        "coin_type" : coinType,
        "token_name": tokenName,
      };
      if (amount.isNotEmpty)      params["amount"]       = amount;
      if (tokenAmount.isNotEmpty) params["token_amount"] = tokenAmount;
      final String fromName = AppGlobals.userInfo?.name ?? "";
      if (fromName.isNotEmpty)    params["from_name"]    = fromName;

      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/payment/receipt',
        params: {},
        data: params,
        header: header,
      );
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'] ?? 'Failed to send payment receipt';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// 获取当前用户的支付历史记录（收款 + 付款）
  Future<MessageModel> getPaymentHistory({int page = 1, int pageSize = 20}) async {
    try {
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.get(
        '$url/v1/lr/payment/history',
        params: {
          "uuid": AppGlobals.userInfo?.uuid ?? "",
          "token": AppGlobals.userInfo?.token ?? "",
          "source": "app",
          "page": page,
          "page_size": pageSize,
        },
        header: header,
      );
      if (data['code'] == 200) {
        mm.data = (data['data'] as List?) ?? [];
      } else {
        mm.error = true;
        mm.data = data['err'] ?? 'Failed';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
