import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/avatar_decoration_preset.dart';
import 'package:n42_chat/src/presentation/widgets/common/n42_avatar.dart';

void main() {
  testWidgets('renders decoration badge when preset is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: N42Avatar(
            name: 'Arcade',
            decorationPreset: AvatarDecorationPreset.arcade,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.sports_esports), findsOneWidget);
  });

  testWidgets('does not render decoration badge for default preset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: N42Avatar(name: 'Default')),
      ),
    );

    expect(find.byIcon(Icons.sports_esports), findsNothing);
    expect(find.byIcon(Icons.auto_awesome), findsNothing);
  });
}
