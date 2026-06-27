import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/core/services/ai_sticker_service.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';

class _MockAi extends Mock implements AiService {}

class _MockStickers extends Mock implements IStickerRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  late _MockAi ai;
  late _MockStickers stickers;
  late AiStickerService svc;

  setUp(() {
    ai = _MockAi();
    stickers = _MockStickers();
    svc = AiStickerService(ai, stickers);
  });

  test('isAvailable reflects ai.supportsImageGeneration', () {
    when(() => ai.supportsImageGeneration).thenReturn(true);
    expect(svc.isAvailable, isTrue);
    when(() => ai.supportsImageGeneration).thenReturn(false);
    expect(svc.isAvailable, isFalse);
  });

  test('generate wraps prompt in sticker style and delegates', () async {
    when(
      () => ai.generateImage(any(), size: any(named: 'size')),
    ).thenAnswer((_) async => AiImageResult(bytes: Uint8List.fromList([1])));

    final r = await svc.generate('orange cat');
    expect(r.bytes, [1]);

    final captured = verify(
      () => ai.generateImage(captureAny(), size: any(named: 'size')),
    ).captured.single as String;
    expect(captured, contains('orange cat'));
    expect(captured.toLowerCase(), contains('sticker'));
  });

  test('empty prompt throws without hitting AI', () async {
    expect(() => svc.generate('   '), throwsA(isA<AiServiceException>()));
    verifyNever(() => ai.generateImage(any(), size: any(named: 'size')));
  });

  test('addToPack creates AI pack when missing, then adds', () async {
    when(() => stickers.getInstalledPacks())
        .thenAnswer((_) async => <StickerPack>[]);
    when(
      () => stickers.createCustomPack(
        name: any(named: 'name'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => const StickerPack(id: 'ai1', name: 'AI Stickers'));
    when(
      () => stickers.addStickerToPack(
        packId: any(named: 'packId'),
        imageBytes: any(named: 'imageBytes'),
        filename: any(named: 'filename'),
        name: any(named: 'name'),
        emoji: any(named: 'emoji'),
      ),
    ).thenAnswer((_) async => true);

    final ok = await svc.addToPack(Uint8List.fromList([1, 2]), label: 'cat');
    expect(ok, isTrue);

    verify(
      () => stickers.createCustomPack(
        name: AiStickerService.aiPackName,
        description: any(named: 'description'),
      ),
    ).called(1);
    verify(
      () => stickers.addStickerToPack(
        packId: 'ai1',
        imageBytes: any(named: 'imageBytes'),
        filename: any(named: 'filename'),
        name: 'cat',
        emoji: any(named: 'emoji'),
      ),
    ).called(1);
  });

  test('addToPack reuses existing AI pack', () async {
    when(() => stickers.getInstalledPacks()).thenAnswer(
      (_) async => const [StickerPack(id: 'existing', name: 'AI Stickers')],
    );
    when(
      () => stickers.addStickerToPack(
        packId: any(named: 'packId'),
        imageBytes: any(named: 'imageBytes'),
        filename: any(named: 'filename'),
        name: any(named: 'name'),
        emoji: any(named: 'emoji'),
      ),
    ).thenAnswer((_) async => true);

    await svc.addToPack(Uint8List.fromList([1]), label: 'x');

    verifyNever(
      () => stickers.createCustomPack(
        name: any(named: 'name'),
        description: any(named: 'description'),
      ),
    );
    verify(
      () => stickers.addStickerToPack(
        packId: 'existing',
        imageBytes: any(named: 'imageBytes'),
        filename: any(named: 'filename'),
        name: any(named: 'name'),
        emoji: any(named: 'emoji'),
      ),
    ).called(1);
  });

  test('generateAndAdd generates then adds, returns image', () async {
    when(
      () => ai.generateImage(any(), size: any(named: 'size')),
    ).thenAnswer((_) async => AiImageResult(bytes: Uint8List.fromList([7, 7])));
    when(() => stickers.getInstalledPacks())
        .thenAnswer((_) async => <StickerPack>[]);
    when(
      () => stickers.createCustomPack(
        name: any(named: 'name'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => const StickerPack(id: 'ai1', name: 'AI Stickers'));
    when(
      () => stickers.addStickerToPack(
        packId: any(named: 'packId'),
        imageBytes: any(named: 'imageBytes'),
        filename: any(named: 'filename'),
        name: any(named: 'name'),
        emoji: any(named: 'emoji'),
      ),
    ).thenAnswer((_) async => true);

    final img = await svc.generateAndAdd('dog');
    expect(img.bytes, [7, 7]);
    verify(
      () => stickers.addStickerToPack(
        packId: 'ai1',
        imageBytes: any(named: 'imageBytes'),
        filename: any(named: 'filename'),
        name: any(named: 'name'),
        emoji: any(named: 'emoji'),
      ),
    ).called(1);
  });
}
