import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';

class ReadApi extends SuiApi {
  final List<dynamic> responses;
  final calls = <List<dynamic>>[];
  ReadApi(this.responses);
  @override
  Future<Result<dynamic, AppError>> baseRPCSui(
    String method,
    dynamic value, {
    bool enableRetry = true,
  }) async {
    calls.add([method, value]);
    return Result.success(responses.removeAt(0));
  }
}

void main() {
  test('coin pagination requests balances and retains every page', () async {
    final api = ReadApi([
      {
        'data': ['first'],
        'hasNextPage': true,
        'nextCursor': 'cursor',
      },
      {
        'data': ['second'],
        'hasNextPage': false,
      },
    ]);
    expect(await api.getOwnedObjects('owner'), ['first', 'second']);
    expect(api.calls[0][0], 'suix_getOwnedObjects');
    expect(api.calls[0][1][1]['options']['showContent'], true);
    expect(api.calls[0][1][2], null);
    expect(api.calls[1][1][2], 'cursor');
  });
  test('cursor loop discards incomplete balance objects', () async {
    final page = {
      'data': ['coin'],
      'hasNextPage': true,
      'nextCursor': 'same',
    };
    final api = ReadApi([page, page]);
    expect(await api.getOwnedObjects('owner'), isEmpty);
    expect(api.calls.length, 2);
  });
  test('malformed later page does not expose a partial selection', () async {
    final api = ReadApi([
      {
        'data': ['coin'],
        'hasNextPage': true,
        'nextCursor': 'next',
      },
      {'data': [], 'hasNextPage': 'false'},
    ]);
    expect(await api.getOwnedObjects('owner'), isEmpty);
  });
  Map<String, dynamic> simulation({
    dynamic computation = '9007199254740993',
    String status = 'success',
    String rebate = '3',
  }) => {
    'effects': {
      'status': {'status': status},
      'gasUsed': {
        'computationCost': computation,
        'storageCost': '2',
        'storageRebate': rebate,
      },
    },
  };
  test(
    'simulation reads nested success and preserves integer precision',
    () async {
      final api = ReadApi([simulation()]);
      final result = await api.dryRunTransactionBlock('unsigned');
      expect(result.error, false);
      expect(result.data, BigInt.parse('9007199254740992'));
      expect(api.calls.single, [
        'sui_dryRunTransactionBlock',
        ['unsigned'],
      ]);
    },
  );
  for (final bad in [null, -1, '1.2', '-1', '']) {
    test('simulation rejects malformed gas $bad', () async {
      final api = ReadApi([simulation(computation: bad)]);
      expect((await api.dryRunTransactionBlock('unsigned')).error, true);
    });
  }
  test('failed simulation never becomes a fee estimate', () async {
    final api = ReadApi([simulation(status: 'failure')]);
    expect((await api.dryRunTransactionBlock('unsigned')).error, true);
  });
  test('storage rebate cannot produce a negative reserved cost', () async {
    final api = ReadApi([simulation(computation: '1', rebate: '100')]);
    expect((await api.dryRunTransactionBlock('unsigned')).data, BigInt.zero);
  });
}
