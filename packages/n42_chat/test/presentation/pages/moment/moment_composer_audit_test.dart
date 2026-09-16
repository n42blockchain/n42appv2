import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_event.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';
import 'package:n42_chat/src/presentation/pages/moment/create_moment_page.dart';

class _Moments extends Mock implements MomentBloc {}

class _Contacts extends Mock implements ContactBloc {}

class _Picker extends ImagePickerPlatform {
  Completer<XFile?>? pending;
  int calls = 0;
  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    calls++;
    return pending?.future ??
        Future.value(
          XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'clip.mp4',
            mimeType: 'video/mp4',
          ),
        );
  }
}

void main() {
  late _Moments moments;
  late _Contacts contacts;
  late _Picker picker;
  late ImagePickerPlatform original;
  setUpAll(() => registerFallbackValue(const PostTextMoment(content: '')));
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    moments = _Moments();
    contacts = _Contacts();
    picker = _Picker();
    original = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = picker;
    when(() => moments.state).thenReturn(const MomentState());
    when(() => moments.stream).thenAnswer((_) => const Stream.empty());
    when(() => contacts.state).thenReturn(
      const ContactState(
        status: ContactStatus.loaded,
        contacts: [
          ContactEntity(
            userId: '@alice:hs',
            displayName: 'Alice',
            isFriend: true,
          ),
        ],
      ),
    );
    when(() => contacts.stream).thenAnswer((_) => const Stream.empty());
  });
  tearDown(() => ImagePickerPlatform.instance = original);
  Widget app({bool video = false}) => MultiBlocProvider(
    providers: [
      BlocProvider<MomentBloc>.value(value: moments),
      BlocProvider<ContactBloc>.value(value: contacts),
    ],
    child: MaterialApp(
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: CreateMomentPage(videoOnly: video),
    ),
  );

  for (final video in [false, true]) {
    testWidgets(
      '${video ? 'video' : 'text'} publishing retains selected audience',
      (tester) async {
        await tester.pumpWidget(app(video: video));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Caption');
        if (video) {
          await tester.tap(find.text('Select video'));
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(find.text('Public'));
        await tester.tap(find.text('Public'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selected Friends'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Alice'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Send'));
        await tester.pump();
        final event = verify(() => moments.add(captureAny())).captured.single;
        if (video) {
          expect(event, isA<PostVideoMoment>());
          expect((event as PostVideoMoment).visibilityUserIds, ['@alice:hs']);
          expect(event.visibility, MomentVisibility.partial);
        } else {
          expect((event as PostTextMoment).visibilityUserIds, ['@alice:hs']);
          expect(event.visibility, MomentVisibility.partial);
        }
      },
    );
  }

  testWidgets('late picker result is ignored after leaving the composer', (
    tester,
  ) async {
    picker.pending = Completer<XFile?>();
    await tester.pumpWidget(app(video: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select video'));
    await tester.tap(find.text('Select video'));
    expect(picker.calls, 1);
    await tester.pumpWidget(const SizedBox());
    picker.pending!.complete(
      XFile.fromData(Uint8List.fromList([1]), name: 'late.mp4'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    verifyNever(() => moments.add(any()));
  });
}
