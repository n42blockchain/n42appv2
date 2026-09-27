import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

const counterChannel = MethodChannel('ai.n42.fixture/datastore_counter');

void requireValue(bool condition, String description) {
  if (!condition) {
    throw StateError(description);
  }
}

SharedPreferencesAsync dataStorePreferences() => SharedPreferencesAsync(
  options: const SharedPreferencesAsyncAndroidOptions(
    backend: SharedPreferencesAndroidBackendLibrary.DataStore,
  ),
);

Future<Map<String, dynamic>> incrementNativeCounter(
  int before,
  int after,
) async {
  final value = await counterChannel.invokeMapMethod<String, dynamic>(
    'increment',
  );
  requireValue(value != null, 'native counter did not return a result');
  final counter = value!;
  requireValue(
    counter['before'] == before,
    'native counter previous value differs',
  );
  requireValue(counter['after'] == after, 'native counter increment differs');
  requireValue(
    (counter['lookupPath'] as String).endsWith(
      'base.apk!/lib/arm64-v8a/libdatastore_shared_counter.so',
    ),
    'class loader did not resolve the packaged DataStore native member',
  );
  requireValue(
    (counter['packageMaps'] as List<dynamic>).any(
      (entry) =>
          entry.toString().contains('r-xp') &&
          entry.toString().contains('base.apk'),
    ),
    'the package has no executable mapping',
  );
  return counter;
}

Future<Map<String, dynamic>> runSeed() async {
  final legacy = await SharedPreferences.getInstance();
  await legacy.setString('fixture.remove', 'remove me');
  requireValue(
    legacy.getString('fixture.remove') == 'remove me',
    'legacy setString failed',
  );
  requireValue(await legacy.remove('fixture.remove'), 'legacy remove failed');
  requireValue(
    legacy.getString('fixture.remove') == null,
    'legacy remove did not persist',
  );
  await legacy.setString('fixture.clear', 'clear me');
  requireValue(await legacy.clear(), 'legacy clear failed');
  requireValue(
    legacy.getString('fixture.clear') == null,
    'legacy clear did not clear',
  );
  await legacy.setBool('fixture.bool', true);
  await legacy.setInt('fixture.int', 42);
  await legacy.setDouble('fixture.double', 3.25);
  await legacy.setString('fixture.string', 'legacy value');
  await legacy.setStringList('fixture.list', ['one', 'two,three']);
  requireValue(
    legacy.getKeys().containsAll(['fixture.bool', 'fixture.list']),
    'legacy key enumeration failed',
  );
  requireValue(
    listEquals(legacy.getStringList('fixture.list'), ['one', 'two,three']),
    'legacy string-list codec failed',
  );

  final dataStore = dataStorePreferences();
  await dataStore.setString('fixture.remove', 'remove me');
  requireValue(
    await dataStore.getString('fixture.remove') == 'remove me',
    'DataStore set failed',
  );
  await dataStore.remove('fixture.remove');
  requireValue(
    await dataStore.getString('fixture.remove') == null,
    'DataStore remove failed',
  );
  await dataStore.setString('fixture.clear', 'clear me');
  await dataStore.clear();
  requireValue(
    await dataStore.getString('fixture.clear') == null,
    'DataStore clear failed',
  );
  await dataStore.setBool('fixture.bool', false);
  await dataStore.setInt('fixture.int', 73);
  await dataStore.setDouble('fixture.double', 2.5);
  await dataStore.setString('fixture.string', 'datastore value');
  await dataStore.setStringList('fixture.list', ['alpha', 'βeta']);
  requireValue(
    (await dataStore.getKeys()).containsAll(['fixture.bool', 'fixture.list']),
    'DataStore key enumeration failed',
  );
  requireValue(
    listEquals(await dataStore.getStringList('fixture.list'), [
      'alpha',
      'βeta',
    ]),
    'DataStore string-list codec failed',
  );

  return {'phase': 'seed', 'counter': await incrementNativeCounter(0, 1)};
}

Future<Map<String, dynamic>> runVerify() async {
  final legacy = await SharedPreferences.getInstance();
  requireValue(
    legacy.getBool('fixture.bool') == true,
    'legacy bool did not survive restart',
  );
  requireValue(
    legacy.getInt('fixture.int') == 42,
    'legacy int did not survive restart',
  );
  requireValue(
    legacy.getDouble('fixture.double') == 3.25,
    'legacy double did not survive restart',
  );
  requireValue(
    legacy.getString('fixture.string') == 'legacy value',
    'legacy string did not survive restart',
  );
  requireValue(
    listEquals(legacy.getStringList('fixture.list'), ['one', 'two,three']),
    'legacy list did not survive restart',
  );
  requireValue(
    legacy.getString('fixture.remove') == null &&
        legacy.getString('fixture.clear') == null,
    'legacy removed or cleared key reappeared',
  );

  final dataStore = dataStorePreferences();
  requireValue(
    await dataStore.getBool('fixture.bool') == false,
    'DataStore bool lost',
  );
  requireValue(
    await dataStore.getInt('fixture.int') == 73,
    'DataStore int lost',
  );
  requireValue(
    await dataStore.getDouble('fixture.double') == 2.5,
    'DataStore double lost',
  );
  requireValue(
    await dataStore.getString('fixture.string') == 'datastore value',
    'DataStore string lost',
  );
  requireValue(
    listEquals(await dataStore.getStringList('fixture.list'), [
      'alpha',
      'βeta',
    ]),
    'DataStore list lost',
  );
  requireValue(
    await dataStore.getString('fixture.remove') == null &&
        await dataStore.getString('fixture.clear') == null,
    'DataStore removed or cleared key reappeared',
  );

  return {'phase': 'verify', 'counter': await incrementNativeCounter(1, 2)};
}
