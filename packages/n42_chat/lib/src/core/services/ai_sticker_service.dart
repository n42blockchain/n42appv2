import 'dart:typed_data';

import '../../domain/entities/sticker_pack_entity.dart';
import '../../domain/repositories/sticker_repository.dart';
import 'ai_service.dart';

/// AI 生成贴纸服务
///
/// 用云端 AI 文生图（[AiService.generateImage]）把一句文字 prompt 生成为贴纸，
/// 加入用户的「AI Stickers」自定义包，之后可在贴纸面板正常发送。
///
/// 对标 iMessage Genmoji / WhatsApp Meta imagine sticker。端侧 Gemma 不出图，
/// [AiProviderRouter] 会统一走云端；云端不可用时 [isAvailable]=false，UI 隐藏入口。
class AiStickerService {
  AiStickerService(this._ai, this._stickers);

  final AiService _ai;
  final IStickerRepository _stickers;

  /// AI 贴纸专用包名
  static const String aiPackName = 'AI Stickers';

  /// 云端是否支持文生图（决定 UI 是否展示「AI 生成」入口）
  bool get isAvailable => _ai.supportsImageGeneration;

  /// 仅生成预览（不入库）。返回 PNG 字节，供 UI 预览后再决定是否添加。
  Future<AiImageResult> generate(String prompt) {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      throw const AiServiceException('Prompt is empty');
    }
    return _ai.generateImage(_stickerStylePrompt(trimmed), size: '1024x1024');
  }

  /// 把生成的贴纸字节加入「AI Stickers」包（包不存在则自动创建）。
  Future<bool> addToPack(Uint8List bytes, {required String label}) async {
    final pack = await _ensureAiPack();
    if (pack == null) {
      throw const AiServiceException('Failed to create AI sticker pack');
    }
    return _stickers.addStickerToPack(
      packId: pack.id,
      imageBytes: bytes,
      filename: 'ai_${DateTime.now().millisecondsSinceEpoch}.png',
      name: label.trim().isEmpty ? 'AI sticker' : label.trim(),
      emoji: '✨',
    );
  }

  /// 一步：生成并加入包，返回生成的图片字节（失败抛 [AiServiceException]）。
  Future<AiImageResult> generateAndAdd(String prompt) async {
    final image = await generate(prompt);
    await addToPack(image.bytes, label: prompt);
    return image;
  }

  /// 把用户 prompt 包装为"贴纸风格"提示词，提升出图的贴纸观感。
  String _stickerStylePrompt(String prompt) =>
      '$prompt, cute die-cut sticker, bold clean outline, flat vibrant colors, '
      'centered subject, solid white background, no text, high contrast';

  Future<StickerPack?> _ensureAiPack() async {
    final installed = await _stickers.getInstalledPacks();
    for (final pack in installed) {
      if (pack.name == aiPackName) return pack;
    }
    return _stickers.createCustomPack(
      name: aiPackName,
      description: 'AI generated stickers',
    );
  }
}
