import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/pages/contact/add_friend_page.dart';

Widget _buildTestApp({required MediaQueryData mediaQuery}) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: MediaQuery(data: mediaQuery, child: const AddFriendPage()),
  );
}

void main() {
  testWidgets('AddFriendPage does not overflow when keyboard is visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const mediaQuery = MediaQueryData(
      size: Size(320, 640),
      viewInsets: EdgeInsets.only(bottom: 260),
    );

    await tester.pumpWidget(_buildTestApp(mediaQuery: mediaQuery));
    await tester.pump();

    expect(find.text('Add Friend'), findsOneWidget);
    expect(find.text('Search user to start chatting'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
