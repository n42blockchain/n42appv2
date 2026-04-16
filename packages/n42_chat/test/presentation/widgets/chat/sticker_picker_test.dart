import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';
import 'package:n42_chat/src/presentation/widgets/chat/sticker_picker.dart';

class _MockStickerRepository extends Mock implements IStickerRepository {}

class _MockMatrixClientManager extends Mock implements MatrixClientManager {}

class _MockClient extends Mock implements matrix.Client {}

void main() {
  late _MockStickerRepository repository;
  late _MockMatrixClientManager clientManager;
  late _MockClient client;

  setUp(() async {
    repository = _MockStickerRepository();
    clientManager = _MockMatrixClientManager();
    client = _MockClient();

    await getIt.reset();
    getIt.registerSingleton<IStickerRepository>(repository);
    getIt.registerSingleton<MatrixClientManager>(clientManager);

    when(
      () => repository.getRecentStickers(limit: any(named: 'limit')),
    ).thenAnswer((_) async => []);
    when(() => repository.getInstalledPacks()).thenAnswer(
      (_) async => const [
        StickerPack(
          id: 'pack-1',
          name: 'Animals',
          stickers: [
            Sticker(
              id: 'cat',
              url: 'mxc://cdn.example.com/cat123',
              httpUrl:
                  'https://matrix.example.com/_matrix/client/v1/media/download/cdn.example.com/cat123',
            ),
          ],
        ),
      ],
    );

    when(() => clientManager.client).thenReturn(client);
    when(
      () => client.homeserver,
    ).thenReturn(Uri.parse('https://matrix.example.com'));
    when(() => client.accessToken).thenReturn('secret-token');
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'sticker picker applies authenticated media headers to sticker images',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickerPicker(
              onStickerSelected: (selectedSticker, selectedPackId) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is NetworkImage,
        ),
      );
      final provider = image.image as NetworkImage;

      expect(
        provider.url,
        'https://matrix.example.com/_matrix/client/v1/media/download/cdn.example.com/cat123',
      );
      expect(provider.headers, const {'Authorization': 'Bearer secret-token'});
    },
  );
}
