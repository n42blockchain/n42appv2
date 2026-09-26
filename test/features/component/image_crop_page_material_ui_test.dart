import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:n42_wallet/features/component/pages/image_crop_page.dart';

void main() {
  testWidgets('image editor receives Material UI localizations', (
    tester,
  ) async {
    final image = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4'
      '//8/AwAI/AL+XH8zAAAAAElFTkSuQmCC',
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => MaterialApp(
          localizationsDelegates: [
            ...material_ui.GlobalMaterialLocalizations.delegates,
          ],
          home: ImageCropPage(image),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ImageCropPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
