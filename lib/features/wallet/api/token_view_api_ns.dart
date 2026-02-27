part of 'token_view_api.dart';

// ── Name Services (ENS / N42NS / Unstoppable Domains / SNS) ───────────────

extension TokenViewApiNameService on TokenViewApi {
  // ── ENS (Ethereum Name Service) ────────────────────────────────────────

  /// ENS 正向解析
  Future<MessageModel> getEnsResolve(String domain) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ens/resolve?domain=$domain',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// N42 链专用 ENS 解析（支持 .n42 后缀域名）
  Future<MessageModel> getN42EnsResolve(String domain) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/n42/ens/resolve?domain=$domain',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// ENS 反向解析（地址 → 名称）
  Future<MessageModel> getEnsReverseResolve(String address) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ens/reverse?address=$address',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// N42 ENS 反向解析
  Future<MessageModel> getN42ReverseResolve(String address) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/n42/ens/reverse?address=$address',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 ENS 头像
  Future<MessageModel> getEnsAvatar(String domain) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ens/avatar?domain=$domain',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 ENS 文本记录（email、twitter、github 等）
  Future<MessageModel> getEnsTextRecords(String domain) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ens/text-records?domain=$domain',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // ── Unstoppable Domains ──────────────────────────────────────────────────

  /// Unstoppable Domains 正向解析
  ///
  /// [domain] — 域名（如 alice.crypto）
  /// [ticker] — 目标链代币符号（ETH / BNB / MATIC / BTC / SOL 等）
  Future<MessageModel> getUdResolve(String domain, {String? ticker}) async {
    try {
      final tickerParam = ticker != null ? '&ticker=$ticker' : '';
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ud/resolve?domain=$domain$tickerParam',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Unstoppable Domains 反向解析
  ///
  /// [address] — 链地址
  /// [ticker]  — 地址所属链的代币符号
  Future<MessageModel> getUdReverseResolve(
    String address, {
    String? ticker,
  }) async {
    try {
      final tickerParam = ticker != null ? '&ticker=$ticker' : '';
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ud/reverse?address=$address$tickerParam',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // ── Solana Name Service (SNS / Bonfida) ──────────────────────────────────

  /// SNS 正向解析：.sol 域名 → Solana 地址
  Future<MessageModel> getSnsResolve(String domain) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/sns/resolve?domain=$domain',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// SNS 反向解析：Solana 地址 → .sol 域名
  Future<MessageModel> getSnsReverseResolve(String address) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/sns/reverse?address=$address',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
