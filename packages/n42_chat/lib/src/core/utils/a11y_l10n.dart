import 'package:flutter/widgets.dart';

/// 无障碍（Semantics）标签的本地化辅助。
///
/// 为什么单独存在、不走 `S`(gen-l10n)：本包 `flutter gen-l10n` 因历史遗留的
/// 非模板 locale 重复声明 placeholder 类型而无法干净再生成（与无障碍工作无关），
/// 故无障碍状态/描述词改由此自包含辅助本地化——覆盖 en / 简体中文 / 繁体中文，
/// 其余语言回退英文。屏幕阅读器播报文案集中于此，便于后续补语言或并入 ARB。
///
/// 用法：`A11yL10n.of(context).sending`。
class A11yL10n {
  /// 归一化后的语言标签：'zh'(简) / 'zh_TW'(繁) / 'en'(其余回退)。
  final String _lang;

  const A11yL10n(this._lang);

  factory A11yL10n.of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return A11yL10n(_normalize(locale));
  }

  static String _normalize(Locale? locale) {
    if (locale == null) return 'en';
    if (locale.languageCode != 'zh') return 'en';
    // 繁体：脚本 Hant 或 港澳台地区
    final isTraditional = locale.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(locale.countryCode);
    return isTraditional ? 'zh_TW' : 'zh';
  }

  String _pick(String zh, String tw, String en) =>
      _lang == 'zh' ? zh : (_lang == 'zh_TW' ? tw : en);

  // —— 输入栏 ——
  String get switchToKeyboard => _pick('键盘', '鍵盤', 'Keyboard');
  String get voice => _pick('语音', '語音', 'Voice');
  String get quickReply => _pick('快捷回复', '快捷回覆', 'Quick reply');
  String get emoji => _pick('表情', '表情', 'Emoji');
  String get attachments => _pick('附件', '附件', 'Attachments');
  String get send => _pick('发送', '傳送', 'Send');
  String get holdToTalk => _pick('按住说话', '按住說話', 'Hold to talk');

  // —— 消息气泡状态 ——
  String get sending => _pick('发送中', '傳送中', 'Sending');
  String get failedToSendTapResend =>
      _pick('发送失败，点按重发', '傳送失敗，點按重新傳送', 'Failed to send, tap to resend');

  // —— 会话列表状态词 ——
  String get locked => _pick('已锁定', '已鎖定', 'locked');
  String get encrypted => _pick('已加密', '已加密', 'encrypted');
  String get muted => _pick('已静音', '已靜音', 'muted');
  String unreadCount(int count) =>
      _pick('$count 条未读', '$count 則未讀', '$count unread');

  // —— 语音消息 ——
  String voiceMessageDuration(int seconds) => _pick(
        '语音消息，$seconds 秒',
        '語音訊息，$seconds 秒',
        'Voice message, $seconds seconds',
      );
  String get playing => _pick('播放中', '播放中', 'playing');
  String get unplayed => _pick('未播放', '未播放', 'unplayed');

  // —— 图片 ——
  String get image => _pick('图片', '圖片', 'Image');
  String imageIndex(int index) => _pick('图片 $index', '圖片 $index', 'Image $index');
  String imageIndexMore(int index, int more) => _pick(
        '图片 $index，还有 $more 张',
        '圖片 $index，還有 $more 張',
        'Image $index, $more more',
      );

  // —— 表情反应 ——
  String reaction(String emoji, int count) =>
      _pick('$emoji 反应，$count', '$emoji 反應，$count', '$emoji reaction, $count');
  String get addReaction => _pick('添加反应', '新增反應', 'Add reaction');
  String get moreReactions => _pick('更多反应', '更多反應', 'More reactions');

  // —— 表情/贴纸面板 ——
  String get tabRecent => _pick('最近', '最近', 'Recent');
  String get tabSticker => _pick('贴纸', '貼圖', 'Sticker');
  String get tabGif => _pick('GIF', 'GIF', 'GIF');
  String get backspace => _pick('删除', '刪除', 'Backspace');
  String get clearSearch => _pick('清除搜索', '清除搜尋', 'Clear search');
  String get stickerStore => _pick('贴纸商店', '貼圖商店', 'Sticker store');
  String get stickerPack => _pick('贴纸包', '貼圖包', 'Sticker pack');
  String stickerNamed(String emoji) =>
      _pick('贴纸，$emoji', '貼圖，$emoji', 'Sticker, $emoji');
  String get videoSticker => _pick('视频贴纸', '影片貼圖', 'Video sticker');

  // —— 消息类型 ——
  String get copyCode => _pick('复制代码', '複製程式碼', 'Copy code');
  String contactCard(String name) =>
      _pick('名片，$name', '名片，$name', 'Contact card, $name');
  String openLink(String title) =>
      _pick('打开链接，$title', '開啟連結，$title', 'Open link, $title');
  String get aiSummary => _pick('AI 摘要', 'AI 摘要', 'AI summary');
  String get expand => _pick('展开', '展開', 'Expand');
  String get collapse => _pick('收起', '收合', 'Collapse');
  String music(String title, String artist) =>
      _pick('音乐，$title，$artist', '音樂，$title，$artist', 'Music, $title, $artist');
  String get addToCalendar => _pick('加入日历', '加入行事曆', 'Add to calendar');
  String pollOption(String text, int votes) =>
      _pick('$text，$votes 票', '$text，$votes 票', '$text, $votes votes');
  String file(String name) => _pick('文件，$name', '檔案，$name', 'File, $name');
  String location(String name) =>
      _pick('位置，$name', '位置，$name', 'Location, $name');
  String get tip => _pick('打赏', '打賞', 'Tip');
  String get redPacketOpened => _pick('已领取', '已領取', 'opened');
  String get redPacketUnopened => _pick('未领取', '未領取', 'unopened');

  // —— Live-region 主动播报（新消息 / 输入中） ——
  String newMessageFrom(String sender) =>
      _pick('$sender 发来新消息', '$sender 傳來新訊息', 'New message from $sender');
  String newMessageFromWithText(String sender, String text) => _pick(
        '$sender 发来新消息：$text',
        '$sender 傳來新訊息：$text',
        'New message from $sender: $text',
      );
  String userTyping(String name) =>
      _pick('$name 正在输入', '$name 正在輸入', '$name is typing');
  String peopleTyping(int count) =>
      _pick('$count 人正在输入', '$count 人正在輸入', '$count people typing');

  // —— 设置页表单（#33 长尾） ——
  String get solidColor => _pick('纯色背景', '純色背景', 'Solid color');
  String get gradient => _pick('渐变背景', '漸層背景', 'Gradient');
  String get showPassword => _pick('显示密码', '顯示密碼', 'Show password');
  String get hidePassword => _pick('隐藏密码', '隱藏密碼', 'Hide password');
}
