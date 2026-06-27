/// 已识别的 SSO/OIDC 身份提供方品牌
///
/// Matrix 服务端可配置任意 OIDC/SAML 身份提供方，登录走统一 SSO Web 流程
/// （无需各家原生 SDK，兼容性最好）。这里把服务端返回的 provider id/name
/// 归类到已知品牌，便于 UI 显示对应图标与品牌色；未识别归 [generic]。
enum SsoBrand {
  google,
  apple,
  microsoft,
  github,
  gitlab,
  facebook,
  twitter,
  discord,
  linkedin,
  wechat,
  telegram,
  generic,
}

/// SSO 品牌识别（纯逻辑，便于单测）。
class SsoBrandClassifier {
  SsoBrandClassifier._();

  /// 按 provider id / name 关键字归类（大小写不敏感）。
  static SsoBrand classify(String idOrName) {
    final s = idOrName.toLowerCase();
    bool has(String kw) => s.contains(kw);

    if (has('google')) return SsoBrand.google;
    if (has('apple')) return SsoBrand.apple;
    if (has('microsoft') ||
        has('azure') ||
        has('entra') ||
        has('msft') ||
        has('office365') ||
        has('outlook')) {
      return SsoBrand.microsoft;
    }
    if (has('github')) return SsoBrand.github;
    if (has('gitlab')) return SsoBrand.gitlab;
    if (has('facebook') || has('meta')) return SsoBrand.facebook;
    if (has('twitter') || has(' x ') || s == 'x' || has('x.com')) {
      return SsoBrand.twitter;
    }
    if (has('discord')) return SsoBrand.discord;
    if (has('linkedin')) return SsoBrand.linkedin;
    if (has('wechat') || has('weixin') || has('微信')) return SsoBrand.wechat;
    if (has('telegram')) return SsoBrand.telegram;
    return SsoBrand.generic;
  }
}
