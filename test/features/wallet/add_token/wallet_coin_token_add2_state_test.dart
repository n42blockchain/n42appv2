import 'package:flutter_test/flutter_test.dart';

enum FakeLoad { loading, finish }

class FakeTokenListResult {
  final bool error;
  final List<Map<String, dynamic>> data;

  const FakeTokenListResult({required this.error, this.data = const []});
}

class FakeWalletCoinTokenAdd2State {
  FakeLoad load = FakeLoad.finish;
  List<Map<String, dynamic>> coinlist = [];

  Future<void> getTokenList(FakeTokenListResult result) async {
    load = FakeLoad.loading;
    try {
      if (result.error) return;
      coinlist = result.data
          .where((item) => (item['contract'] ?? '') != '')
          .toList();
    } finally {
      load = FakeLoad.finish;
    }
  }
}

void main() {
  test('getTokenList resets load to finish when request fails', () async {
    final state = FakeWalletCoinTokenAdd2State();

    await state.getTokenList(const FakeTokenListResult(error: true));

    expect(state.load, FakeLoad.finish);
    expect(state.coinlist, isEmpty);
  });

  test('getTokenList keeps contract tokens when request succeeds', () async {
    final state = FakeWalletCoinTokenAdd2State();

    await state.getTokenList(
      const FakeTokenListResult(
        error: false,
        data: [
          {'contract': ''},
          {'contract': '0xabc'},
        ],
      ),
    );

    expect(state.load, FakeLoad.finish);
    expect(state.coinlist, hasLength(1));
  });
}
