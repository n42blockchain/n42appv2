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
  List<XFile> images = [];
  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    source = ImageSource.gallery;
    return images;
  }

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

class _PartialWriteImage extends XFile {
  _PartialWriteImage() : super('unused.jpg');
  @override
  Future<void> saveTo(String path) async {
    await File(path).writeAsBytes([1, 2, 3]);
    throw const FileSystemException('Simulated partial copy');
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
  testWidgets(
    'create a tag from a populated picker and persist it on the friend',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' Work ');
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Confirm'),
        ),
      );
      await tester.pumpAndSettle();
      final row = find.ancestor(
        of: find.text('Work'),
        matching: find.byType(ListTile),
      );
      expect(
        tester
            .widget<Checkbox>(
              find.descendant(of: row, matching: find.byType(Checkbox)),
            )
            .value,
        isTrue,
      );
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect((await store.load())['tags'], ['Work']);
      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();
      expect(find.text('Work'), findsOneWidget);
      expect(
        tester
            .widget<Checkbox>(
              find.descendant(
                of: find.ancestor(
                  of: find.text('Work'),
                  matching: find.byType(ListTile),
                ),
                matching: find.byType(Checkbox),
              ),
            )
            .value,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'creating an existing tag selects it without duplicating the catalog',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' family ');
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Confirm'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect((await store.load())['tags'], ['Family']);
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('tags_data')!) as List, hasLength(1));
    },
  );

  testWidgets(
    'friend profile previews saved fields and refreshes when the editor returns',
    (tester) async {
      await store.save({
        'phone': '15011128888',
        'tags': ['Family', 'Friends'],
        'notes': 'Hello',
      });
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: ContactDetailPage(
            userId: '@friend:hs.test',
            displayName: 'Friend',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('15011128888'), findsOneWidget);
      expect(find.text('Family, Friends'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      await tester.tap(find.text('Friend Info'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Phone'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '15122224444');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('15122224444'), findsOneWidget);
      expect(find.text('15011128888'), findsNothing);
    },
  );

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
    'multiple gallery photos persist, preview and delete in the photo manager',
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
      picker.images = [XFile(source.path), XFile(source.path)];
      await open(tester);
      await tester.tap(find.text('Photos'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Add'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect(picker.source, ImageSource.gallery);
      final names = (await store.load())['photos'] as List;
      expect(names, hasLength(2));
      final saved = await tester.runAsync(
        () => store.photo(names.first as String),
      );
      expect(saved!.existsSync(), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await open(tester);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNWidgets(2));
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Photos'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect((await store.load())['photos'], hasLength(1));
      expect(saved.existsSync(), isFalse);
      picker.images = [];
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect((await store.load())['photos'], hasLength(1));
      picker.images = [
        XFile(source.path),
        XFile('${directory.path}/missing.jpg'),
      ];
      await tester.runAsync(() async {
        await tester.tap(find.text('Add'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect((await store.load())['photos'], hasLength(1));
      expect(find.text('Save failed'), findsOneWidget);
      expect(saved.parent.listSync().whereType<File>(), hasLength(1));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: ContactDetailPage(
            userId: '@friend:hs.test',
            displayName: 'Friend',
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('1 photos'), findsOneWidget);
      await tester.ensureVisible(find.byType(Image).first);
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
    },
  );
  testWidgets('failed partial photo copy leaves no orphan file', (
    tester,
  ) async {
    final directory = Directory.systemTemp.createTempSync(
      'friend-photo-partial',
    );
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => directory.path,
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
      directory.deleteSync(recursive: true);
    });
    await tester.runAsync(() async {
      await expectLater(
        store.importPhoto(_PartialWriteImage()),
        throwsA(isA<FileSystemException>()),
      );
      expect(directory.listSync(recursive: true).whereType<File>(), isEmpty);
    });
  });

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
