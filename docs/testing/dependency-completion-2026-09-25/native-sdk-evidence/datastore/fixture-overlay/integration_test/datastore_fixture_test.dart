import 'package:datastore_fixture/fixture_workflow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _phase = String.fromEnvironment('DATASTORE_PHASE');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('legacy and DataStore APIs work in the selected phase', (
    tester,
  ) async {
    final result = switch (_phase) {
      'seed' => await runSeed(),
      'verify' => await runVerify(),
      _ => throw StateError('DATASTORE_PHASE must be seed or verify'),
    };
    expect(result['phase'], _phase);
    expect(result['counter'], isNotNull);
  });
}
