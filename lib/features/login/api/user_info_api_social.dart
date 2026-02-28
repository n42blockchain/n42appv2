part of 'user_info_api.dart';

/// UserInfoApi 第三方登录、邀请、支付、消息、反馈相关扩展
extension UserInfoApiSocial on UserInfoApi {
  /// GET 请求并提取 data 字段的通用辅助（code==200 且 data!=null 时返回 data，否则 null）
  Future<dynamic> _getData(String path, Map<String, dynamic> params) async {
    final data = await BaseApi.requestEmptyH.get(
      '$url$path',
      params: params,
      header: header,
    );
    if (data["code"] == 200 && data["data"] != null) {
      return data["data"];
    }
    return null;
  }

  /// try/catch + MessageModel 包装的通用辅助
  Future<MessageModel> _wrapRequest(Future<MessageModel> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// 第三方登录 - Google
  /// idToken: Google ID Token
  /// accessToken: Google Access Token (optional)
  Future<dynamic> loginWithGoogle(String idToken, {String? accessToken, Map<String, dynamic>? deviceInfo}) async {
    final Map<String, dynamic> params = {
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
    final Map<String, dynamic> params = {
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
    final Map<String, dynamic> params = {
      "firebase_token": pushToken,
      "uuid": AppGlobals.userInfo?.uuid ?? "",
      "token": AppGlobals.userInfo?.token ?? "",
      "source": "app",
    };
    if (deviceId != null) {
      params["device_id"] = deviceId;
    }
    final data = await BaseApi.requestEmptyH.post(
      '$url/v1/l/file/bind/firebase/token',
      params: {},
      data: params,
      header: header,
    );
    return data;
  }

  //获取邀请人code
  Future getInviterCode(
      String mobileModel, String mobileName, String os) async {
    return _getData('/v1/r/user/inviter/code', {
      "mobile_model": mobileModel,
      "mobile_name": mobileName,
      "os": os,
    });
  }

  //获取邀请用户，挖矿收益
  Future getInviteeMiningInfo(String uuid) async {
    return _getData('/v1/r/user/invitee/mining/fullnode', {"uuid": uuid});
  }

  Future getInviteeMiningCount(String uuid) async {
    return _getData('/v1/r/user/invitee/mining', {"uuid": uuid});
  }

  //获取邀请用户，下载app的数量
  Future getInviteeDownloadList(String uuid,
      {int pagenum = 1, int pagesize = 1}) async {
    return _getData('/v1/r/user/invitee/list/download', {
      "uuid": uuid,
      "page_size": pagesize,
      "page_num": pagenum,
    });
  }

  //获取用户邀请的人数
  Future getInviteeList(String uuid) async {
    return _getData('/v1/r/user/invitee/list', {"uuid": uuid});
  }

  //提交反馈信息,address钱包地址，content反馈内容，extra附件地址
  Future<MessageModel> submitFeedback(String address, String content, String extra) async {
    return _wrapRequest(() async {
      final mm = MessageModel();
      mm.data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/feedback',
        params: {},
        data: {
          "uuid": AppGlobals.userInfo?.uuid ?? "",
          "source": "app",
          "token": AppGlobals.userInfo?.token ?? "",
          "wallet_addr": address,
          "content": content,
          "extra": extra,
        },
        header: header,
        addUserInfo: true,
      );
      return mm;
    });
  }

  //获取 消息列表
  Future<MessageModel> getMsgNoticeList({int page = 1, int pageSize = 10, String msgType = ""}) async {
    return _wrapRequest(() async {
      final mm = MessageModel();
      final data = await BaseApi.requestEmptyH.get(
        '$url/v1/lr/get/msg/notice/list',
        params: {
          "uuid": AppGlobals.userInfo?.uuid ?? "",
          "page": page,
          "page_size": pageSize,
          "msg_type": msgType,
          "token": AppGlobals.userInfo?.token ?? "",
          "source": "app",
        },
        header: header,
      );
      if (data['code'] == 200) {
        mm.data = data['data'];
      } else {
        mm.error = true;
        mm.data = data['err'];
      }
      return mm;
    });
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
    return _wrapRequest(() async {
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

      final mm = MessageModel();
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
    });
  }

  /// 获取当前用户的支付历史记录（收款 + 付款）
  Future<MessageModel> getPaymentHistory({int page = 1, int pageSize = 20}) async {
    return _wrapRequest(() async {
      final mm = MessageModel();
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
    });
  }
}
