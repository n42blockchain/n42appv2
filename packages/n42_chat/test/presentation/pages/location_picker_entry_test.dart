import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/pages/chat/location_picker_page.dart';

class _PositionSource extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => Position(
    longitude: 20,
    latitude: 10,
    timestamp: DateTime(2026),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _Places extends GeocodingPlatform {
  final queries = <String, Completer<List<Location>>>{};
  @override
  Future<List<Location>> locationFromAddress(String address) =>
      (queries[address] = Completer<List<Location>>()).future;
  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async => [Placemark(name: 'Place $latitude', street: 'Street $latitude')];
}

void main() {
  late _Places places;
  setUp(() {
    final originalPosition = GeolocatorPlatform.instance;
    final originalPlaces = GeocodingPlatform.instance;
    addTearDown(() {
      GeolocatorPlatform.instance = originalPosition;
      GeocodingPlatform.instance = originalPlaces ?? _Places();
    });
    GeolocatorPlatform.instance = _PositionSource();
    GeocodingPlatform.instance = places = _Places();
  });

  testWidgets(
    'current position has no invented nearby POIs and stale searches are ignored',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: ChatLocationPickerPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Nearby Place 1'), findsNothing);
      expect(find.text('Nearby Place 2'), findsNothing);
      expect(find.text('My location'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'old');
      await tester.pump(const Duration(milliseconds: 550));
      await tester.enterText(find.byType(TextField), 'new');
      await tester.pump(const Duration(milliseconds: 550));
      places.queries['new']!.complete([
        Location(latitude: 30, longitude: 40, timestamp: DateTime(2026)),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Place 30.0'), findsOneWidget);
      places.queries['old']!.complete([
        Location(latitude: 50, longitude: 60, timestamp: DateTime(2026)),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Place 30.0'), findsOneWidget);
      expect(find.text('Place 50.0'), findsNothing);
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('My location'), findsOneWidget);
      expect(find.text('Place 30.0'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('relocate sends GPS coordinates and invalidates pending search', (
    tester,
  ) async {
    Map<String, dynamic>? selected;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              selected = await Navigator.of(context).push<Map<String, dynamic>>(
                MaterialPageRoute(
                  builder: (_) => const ChatLocationPickerPage(),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'destination');
    await tester.pump(const Duration(milliseconds: 550));
    places.queries['destination']!.complete([
      Location(latitude: 30, longitude: 40, timestamp: DateTime(2026)),
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Place 30.0'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'pending');
    await tester.pump(const Duration(milliseconds: 550));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    places.queries['pending']!.complete([
      Location(latitude: 50, longitude: 60, timestamp: DateTime(2026)),
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('My location'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected?['latitude'], 10);
    expect(selected?['longitude'], 20);
    expect(selected?['address'], '10.000000, 20.000000');
  });
}
