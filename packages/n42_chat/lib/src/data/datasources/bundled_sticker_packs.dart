import '../../domain/entities/sticker_pack_entity.dart';

/// 内置（随包分发）贴纸包
///
/// 素材来自 **OpenMoji**（https://openmoji.org，CC BY-SA 4.0），彩色 SVG，
/// 以 Unicode 码点命名（如 `1F600.svg`）打进 App 包。署名见
/// `assets/stickers/openmoji/LICENSE.txt`。
///
/// 这些贴纸**收发双方都本地持有**，因此：
/// - 贴纸 `url` 用 `asset:` scheme 指向打包资源（`asset:assets/stickers/openmoji/<码点>.svg`）；
/// - 发送时把 SVG 字节上传 Matrix 媒体库换 mxc（带缓存），发标准 `m.sticker`，
///   接收端（含其它客户端）可下载渲染；本端用 `SvgPicture.asset` 直渲；
/// - `emoji` 字段用于搜索与兜底文本。
///
/// 增删/换素材：把对应 OpenMoji 码点 SVG 放进 `assets/stickers/openmoji/`，改下表即可。
class BundledStickerPacks {
  BundledStickerPacks._();

  /// asset url 前缀
  static const String assetScheme = 'asset:';

  /// OpenMoji 静态 SVG 资源目录
  static const String _dir = 'assets/stickers/openmoji';

  /// Noto 动画 Lottie 资源目录
  static const String _dirLottie = 'assets/stickers/lottie';

  static Sticker _s(String pack, String code, String emoji, String name) {
    return Sticker(
      id: '${pack}_$code',
      url: '$assetScheme$_dir/$code.svg',
      name: name,
      emoji: emoji,
      width: 72,
      height: 72,
      mimeType: 'image/svg+xml',
    );
  }

  static Sticker _anim(String code, String emoji, String name) {
    return Sticker(
      id: 'n42_animated_$code',
      url: '$assetScheme$_dirLottie/$code.json',
      name: name,
      emoji: emoji,
      width: 256,
      height: 256,
      mimeType: 'application/lottie+json',
    );
  }

  /// 表情脸贴纸包（OpenMoji smileys）
  static final StickerPack faces = StickerPack(
    id: 'n42_faces',
    name: 'Faces',
    description: 'OpenMoji smileys',
    author: 'OpenMoji',
    source: StickerPackSource.builtin,
    isInstalled: true,
    isOfficial: true,
    stickers: [
      _s('n42_faces', '1F600', '😀', 'Grinning'),
      _s('n42_faces', '1F601', '😁', 'Beaming'),
      _s('n42_faces', '1F602', '😂', 'Joy'),
      _s('n42_faces', '1F603', '😃', 'Smiley'),
      _s('n42_faces', '1F604', '😄', 'Happy'),
      _s('n42_faces', '1F609', '😉', 'Wink'),
      _s('n42_faces', '1F60A', '😊', 'Blush'),
      _s('n42_faces', '1F60B', '😋', 'Yum'),
      _s('n42_faces', '1F60D', '😍', 'Heart eyes'),
      _s('n42_faces', '1F60E', '😎', 'Cool'),
      _s('n42_faces', '1F642', '🙂', 'Slight smile'),
      _s('n42_faces', '1F917', '🤗', 'Hug'),
      _s('n42_faces', '1F914', '🤔', 'Thinking'),
      _s('n42_faces', '1F970', '🥰', 'Adore'),
      _s('n42_faces', '1F622', '😢', 'Cry'),
      _s('n42_faces', '1F62D', '😭', 'Sob'),
      _s('n42_faces', '1F620', '😠', 'Angry'),
      _s('n42_faces', '1F62E', '😮', 'Surprise'),
      _s('n42_faces', '1F634', '😴', 'Sleep'),
    ],
  );

  /// 反应/手势贴纸包（OpenMoji gestures & symbols）
  static final StickerPack reactions = StickerPack(
    id: 'n42_reactions',
    name: 'Reactions',
    description: 'OpenMoji gestures & symbols',
    author: 'OpenMoji',
    source: StickerPackSource.builtin,
    isInstalled: true,
    isOfficial: true,
    stickers: [
      _s('n42_reactions', '1F44D', '👍', 'Thumbs up'),
      _s('n42_reactions', '1F44E', '👎', 'Thumbs down'),
      _s('n42_reactions', '2764', '❤️', 'Heart'),
      _s('n42_reactions', '1F44F', '👏', 'Clap'),
      _s('n42_reactions', '1F525', '🔥', 'Fire'),
      _s('n42_reactions', '1F389', '🎉', 'Party'),
      _s('n42_reactions', '1F44C', '👌', 'OK'),
      _s('n42_reactions', '1F64F', '🙏', 'Pray'),
      _s('n42_reactions', '1F680', '🚀', 'Rocket'),
      _s('n42_reactions', '1F4AF', '💯', 'Hundred'),
      _s('n42_reactions', '1F44B', '👋', 'Wave'),
      _s('n42_reactions', '1F91D', '🤝', 'Handshake'),
      _s('n42_reactions', '270C', '✌️', 'Victory'),
      _s('n42_reactions', '2B50', '⭐', 'Star'),
      _s('n42_reactions', '26A1', '⚡', 'Zap'),
    ],
  );

  /// 动画贴纸包（Noto Animated Emoji，Lottie，Apache-2.0）
  static final StickerPack animated = StickerPack(
    id: 'n42_animated',
    name: 'Animated',
    description: 'Noto Animated Emoji (Lottie)',
    author: 'Google Noto',
    source: StickerPackSource.builtin,
    isInstalled: true,
    isOfficial: true,
    stickers: [
      _anim('1F600', '😀', 'Grinning'),
      _anim('1F602', '😂', 'Joy'),
      _anim('1F609', '😉', 'Wink'),
      _anim('1F60D', '😍', 'Heart eyes'),
      _anim('1F60E', '😎', 'Cool'),
      _anim('1F914', '🤔', 'Thinking'),
      _anim('1F622', '😢', 'Cry'),
      _anim('1F620', '😠', 'Angry'),
      _anim('1F44D', '👍', 'Thumbs up'),
      _anim('1F44E', '👎', 'Thumbs down'),
      _anim('2764', '❤️', 'Heart'),
      _anim('1F44F', '👏', 'Clap'),
      _anim('1F525', '🔥', 'Fire'),
      _anim('1F389', '🎉', 'Party'),
      _anim('1F44C', '👌', 'OK'),
      _anim('1F680', '🚀', 'Rocket'),
    ],
  );

  /// 全部内置包（展示/安装顺序）
  static List<StickerPack> get all => [animated, faces, reactions];

  /// 是否为内置 asset 贴纸
  static bool isAssetSticker(String url) => url.startsWith(assetScheme);

  /// 是否为 Lottie 动画贴纸
  static bool isLottie(String url) => url.toLowerCase().endsWith('.json');

  /// 取出 asset 资源路径（去掉 `asset:` 前缀）
  static String assetPath(String url) =>
      url.startsWith(assetScheme) ? url.substring(assetScheme.length) : url;

  /// 按资源扩展名推断上传 mimetype（SVG / Lottie / WebP / 兜底 PNG）
  static String mimeForAsset(String url) {
    final u = url.toLowerCase();
    if (u.endsWith('.svg')) return 'image/svg+xml';
    if (u.endsWith('.json')) return 'application/lottie+json';
    if (u.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }
}
