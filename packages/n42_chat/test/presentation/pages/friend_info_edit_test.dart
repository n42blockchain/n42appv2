import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/services/friend_details_store.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_detail_page.dart';

class _GalleryPicker extends ImagePickerPlatform {
  XFile? image;
  ImageSource? source;
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    this.source = source;
    return image;
  }
}

void main() {
  final store = FriendDetailsStore(
    'https://hs.test',
    '@me:hs.test',
    '@friend:hs.test',
  );
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'tags_data': jsonEncode([
        {'name': 'Family', 'contactIds': <String>[]},
      ]),
    });
    FlutterSecureStorage.setMockInitialValues({
      'n42_chat_session': jsonEncode({
        'homeserver': 'https://hs.test',
        'userId': '@me:hs.test',
        'accessToken': 'test',
        'deviceId': 'test',
      }),
    });
  });
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: FriendInfoPage(userId: '@friend:hs.test', displayName: 'Friend'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'phone and notes persist and populate their editors after reopening',
    (tester) async {
      await open(tester);
      for (final entry in {
        'Phone': '+1 234 567',
        'Notes': 'Meet on Friday',
      }.entries) {
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), entry.value);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await open(tester);
      expect(find.text('+1 234 567'), findsOneWidget);
      expect(find.text('Meet on Friday'), findsOneWidget);
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Meet on Friday',
      );
      await tester.enterText(find.byType(TextField), 'Discard');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await store.load())['notes'], 'Meet on Friday');
    },
  );
  testWidgets('tag confirmation persists selection', (tester) async {
    await open(tester);
    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect((await store.load())['tags'], ['Family']);
    expect(find.text('Family'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await open(tester);
    expect(find.text('Family'), findsOneWidget);
    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family'));
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect((await store.load())['tags'], isEmpty);
  });
  testWidgets('an account change prevents saving stale friend details', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Do not save');
    FlutterSecureStorage.setMockInitialValues({});
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(await store.load(), isEmpty);
    expect(find.text('Save failed'), findsOneWidget);
  });
  testWidgets('remark editor contains only the remark field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: EditRemarkPage(userId: '@friend:hs.test', displayName: 'Friend'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    for (final label in ['Phone', 'Tags', 'Notes', 'Photos']) {
      expect(find.text(label), findsNothing);
    }
  });
  testWidgets(
    'gallery photos persist, reopen, preview and delete; cancellation is harmless',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'friend-photo-test',
      );
      final picker = _GalleryPicker();
      final previousPicker = ImagePickerPlatform.instance;
      ImagePickerPlatform.instance = picker;
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => directory.path,
      );
      addTearDown(() {
        ImagePickerPlatform.instance = previousPicker;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
        directory.deleteSync(recursive: true);
      });
      final source = File('${directory.path}/source.png')
        ..writeAsBytesSync(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aD1sAAAAASUVORK5CYII=',
          ),
        );
      picker.image = XFile(source.path);
      await open(tester);
      await tester.runAsync(() async {
        await tester.tap(find.text('Photos'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect(picker.source, ImageSource.gallery);
      final names = (await store.load())['photos'] as List;
      expect(names, hasLength(1));
      final saved = await tester.runAsync(
        () => store.photo(names.single as String),
      );
      expect(saved!.existsSync(), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await open(tester);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.delete_outline));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect((await store.load())['photos'], isEmpty);
      expect(saved.existsSync(), isFalse);
      picker.image = null;
      await tester.tap(find.text('Photos'));
      await tester.pumpAndSettle();
      expect((await store.load())['photos'], isEmpty);
    },
  );
  test(
    'details persist independently per server, account and friend',
    () async {
      await store.save({
        'notes': 'Private',
        'photos': ['123.jpg'],
      });
      expect(
        (await FriendDetailsStore(
          'https://hs.test',
          '@me:hs.test',
          '@friend:hs.test',
        ).load())['notes'],
        'Private',
      );
      for (final other in [
        FriendDetailsStore(
          'https://other.test',
          '@me:hs.test',
          '@friend:hs.test',
        ),
        FriendDetailsStore(
          'https://hs.test',
          '@other:hs.test',
          '@friend:hs.test',
        ),
        FriendDetailsStore('https://hs.test', '@me:hs.test', '@other:hs.test'),
      ]) {
        expect(await other.load(), isEmpty);
      }
      expect(() => store.photo('../secret'), throwsArgumentError);
    },
  );
}
