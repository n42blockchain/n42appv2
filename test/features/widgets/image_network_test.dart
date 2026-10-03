import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/eso_image_cachemanager.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('preserves cached image settings and fallback callbacks', (
    tester,
  ) async {
    const imageUrl = 'https://images.example.test/nft.png';
    late CachedNetworkImage image;

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) {
            image =
                ImageNetWork(
                      imageUrl: imageUrl,
                      width: 64,
                      height: 48,
                      fit: BoxFit.contain,
                    ).build(context)
                    as CachedNetworkImage;
            // Keep the image widget unmounted so this test checks configuration
            // without making a real network or platform-cache request.
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(image.imageUrl, imageUrl);
    expect(image.width, 64);
    expect(image.height, 48);
    expect(image.fit, BoxFit.contain);
    expect(image.cacheManager, isA<EsoImageCacheManager>());
    expect(image.placeholder, isNotNull);
    expect(image.errorWidget, isNotNull);
  });

  testWidgets('custom image builder receives the URL and placeholder', (
    tester,
  ) async {
    const imageUrl = 'https://images.example.test/avatar.png';
    String? receivedUrl;
    Widget? receivedPlaceholder;

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => ImageNetWork(
            imageUrl: imageUrl,
            placeholder: 'assets/placeholder.png',
            builder: (context, url, placeholder) {
              receivedUrl = url;
              receivedPlaceholder = placeholder;
              return const Text('custom image');
            },
          ),
        ),
      ),
    );

    expect(receivedUrl, imageUrl);
    expect(receivedPlaceholder, isA<Image>());
    expect(find.text('custom image'), findsOneWidget);
  });
}
