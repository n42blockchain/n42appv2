import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_tile.dart';

void main() {
  const contact = ContactEntity(
    userId: '@alice:example.org',
    displayName: 'Alice',
  );

  testWidgets('contact selection is labeled and can toggle through semantics', (
    tester,
  ) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SimpleContactTile(
              contact: contact,
              selected: selected,
              onTap: () => setState(() => selected = !selected),
            ),
          ),
        ),
      ),
    );

    final tile = find.bySemanticsLabel('Alice');
    expect(tile, findsOneWidget);
    expect(find.bySemanticsLabel('A'), findsNothing);
    var node = tester.getSemantics(tile);
    expect(node, isSemantics(hasCheckedState: true));
    expect(node, isSemantics(isChecked: false));
    expect(node, isSemantics(isEnabled: true));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    tester.semantics.tap(find.semantics.byLabel('Alice'));
    await tester.pump();
    node = tester.getSemantics(tile);
    expect(selected, isTrue);
    expect(node, isSemantics(isChecked: true));

    await tester.tap(find.byType(SimpleContactTile));
    await tester.pump();
    expect(selected, isFalse);
    expect(tester.getSemantics(tile), isSemantics(isChecked: false));
  });

  testWidgets(
    'disabled contact selection retains checked state without action',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleContactTile(contact: contact, selected: true),
          ),
        ),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Alice'));
      expect(node, isSemantics(isChecked: true));
      expect(node, isSemantics(hasEnabledState: true));
      expect(node, isSemantics(isEnabled: false));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    },
  );
}
