import 'package:flutter/widgets.dart';

class ImageTextL10n {
  const ImageTextL10n._(this._languageCode);

  final String _languageCode;

  factory ImageTextL10n.of(BuildContext context) => ImageTextL10n._(
    Localizations.localeOf(context).languageCode.toLowerCase(),
  );

  bool get _zh => _languageCode == 'zh';

  String get extractText => _zh ? '提取文字' : 'Extract text';
  String get translateImage => _zh ? '翻译图片' : 'Translate image';
  String get recognizing => _zh ? '正在识别图片文字…' : 'Recognizing text…';
  String get translating => _zh ? '正在翻译…' : 'Translating…';
  String get noText => _zh ? '未识别到文字' : 'No text found';
  String get retry => _zh ? '重试' : 'Retry';
  String get selectAll => _zh ? '全选' : 'Select all';
  String get clear => _zh ? '取消选择' : 'Clear';
  String get copy => _zh ? '复制' : 'Copy';
  String get share => _zh ? '分享' : 'Share';
  String get forward => _zh ? '转发' : 'Forward';
  String get favorite => _zh ? '收藏' : 'Favorite';
  String get search => _zh ? '搜索' : 'Search';
  String get favorited => _zh ? '已收藏识别文字' : 'Recognized text favorited';
  String get original => _zh ? '原文' : 'Original';
  String get translation => _zh ? '译文' : 'Translation';
  String get targetLanguage => _zh ? '目标语言' : 'Target language';
  String get copied => _zh ? '已复制' : 'Copied';
  String get onDevice => _zh ? '端侧处理' : 'On-device';
  String get cloudFallback => _zh ? '云端翻译' : 'Cloud translation';
  String get unavailable => _zh ? '图片文字处理不可用' : 'Image text unavailable';
  String get protectedImage =>
      _zh ? '阅后即焚图片不支持文字提取' : 'Protected images cannot be processed';
  String get remoteConsentTitle => _zh ? '允许云端翻译？' : 'Allow cloud translation?';
  String get remoteConsentBody => _zh
      ? '端侧语言模型暂不可用。继续后只会发送已识别的文字，不会上传原图。'
      : 'The on-device language model is unavailable. Only recognized text will be sent; the original image will not be uploaded.';
  String get cancel => _zh ? '取消' : 'Cancel';
  String get continueLabel => _zh ? '继续' : 'Continue';
}
