part of 'token_view_api.dart';

// -- Name Services (ENS / N42NS / Unstoppable Domains / SNS) -------------------

extension TokenViewApiNameService on TokenViewApi {
  /// Name service GET 请求通用模板
  Future<MessageModel> _nsGet(String path) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '$url$path',
        params: {},
        header: header,
      );
      if (a['code'] == 200) {
        return MessageModel()..data = a['data'];
      }
      return MessageModel.error()..data = errorMessage(a['msg']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // -- ENS (Ethereum Name Service) --------------------------------------------

  /// ENS 正向解析
  Future<MessageModel> getEnsResolve(String domain) =>
      _nsGet('v1/ens/resolve?domain=$domain');

  /// N42 链专用 ENS 解析（支持 .n42 后缀域名）
  Future<MessageModel> getN42EnsResolve(String domain) =>
      _nsGet('v1/n42/ens/resolve?domain=$domain');

  /// ENS 反向解析（地址 -> 名称）
  Future<MessageModel> getEnsReverseResolve(String address) =>
      _nsGet('v1/ens/reverse?address=$address');

  /// N42 ENS 反向解析
  Future<MessageModel> getN42ReverseResolve(String address) =>
      _nsGet('v1/n42/ens/reverse?address=$address');

  /// 获取 ENS 头像
  Future<MessageModel> getEnsAvatar(String domain) =>
      _nsGet('v1/ens/avatar?domain=$domain');

  /// 获取 ENS 文本记录（email、twitter、github 等）
  Future<MessageModel> getEnsTextRecords(String domain) =>
      _nsGet('v1/ens/text-records?domain=$domain');

  // -- Unstoppable Domains ----------------------------------------------------

  /// Unstoppable Domains 正向解析
  ///
  /// [domain] -- 域名（如 alice.crypto）
  /// [ticker] -- 目标链代币符号（ETH / BNB / MATIC / BTC / SOL 等）
  Future<MessageModel> getUdResolve(String domain, {String? ticker}) {
    final tickerParam = ticker != null ? '&ticker=$ticker' : '';
    return _nsGet('v1/ud/resolve?domain=$domain$tickerParam');
  }

  /// Unstoppable Domains 反向解析
  ///
  /// [address] -- 链地址
  /// [ticker]  -- 地址所属链的代币符号
  Future<MessageModel> getUdReverseResolve(String address, {String? ticker}) {
    final tickerParam = ticker != null ? '&ticker=$ticker' : '';
    return _nsGet('v1/ud/reverse?address=$address$tickerParam');
  }

  // -- Solana Name Service (SNS / Bonfida) ------------------------------------

  /// SNS 正向解析：.sol 域名 -> Solana 地址
  Future<MessageModel> getSnsResolve(String domain) =>
      _nsGet('v1/sns/resolve?domain=$domain');

  /// SNS 反向解析：Solana 地址 -> .sol 域名
  Future<MessageModel> getSnsReverseResolve(String address) =>
      _nsGet('v1/sns/reverse?address=$address');
}
