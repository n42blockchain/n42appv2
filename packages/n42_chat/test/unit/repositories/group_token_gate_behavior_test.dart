import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_group_datasource.dart';
import 'package:n42_chat/src/data/repositories/group_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/token_gate_entity.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_event.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_state.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Room extends Mock implements matrix.Room {}

class _Event extends Mock implements matrix.Event {}

class _Wallet extends Mock implements IWalletBridge {}

void main() {
  late _Manager manager;
  late _Client client;
  late _Room room;
  late _Event state;
  late _Wallet wallet;
  late MatrixGroupDataSource source;
  late GroupRepositoryImpl repository;
  Map<String, dynamic>? raw;
  const roomId = '!fixture:test';
  const contract = '0x1111111111111111111111111111111111111111';
  TokenGateRule rule({
    TokenStandard standard = TokenStandard.erc20,
    BigInt? minimum,
    int chainId = 1,
    String id = 'rule',
  }) => TokenGateRule(
    id: id,
    tokenStandard: standard,
    chainId: chainId,
    contractAddress: standard == TokenStandard.native ? null : contract,
    minBalance: minimum ?? BigInt.from(100),
    tokenId: standard == TokenStandard.erc1155 ? BigInt.from(7) : null,
  );
  void config(
    List<TokenGateRule> rules, {
    GateOperator operator = GateOperator.and,
  }) {
    raw = TokenGateConfig(
      enabled: true,
      rules: rules,
      operator: operator,
    ).toJson();
  }

  setUp(() {
    manager = _Manager();
    client = _Client();
    room = _Room();
    state = _Event();
    wallet = _Wallet();
    source = MatrixGroupDataSource(manager);
    repository = GroupRepositoryImpl(source, manager, walletBridge: wallet);
    raw = null;
    when(() => manager.client).thenReturn(client);
    when(() => client.getRoomById(roomId)).thenReturn(room);
    when(() => client.rooms).thenReturn([]);
    when(() => room.id).thenReturn(roomId);
    when(() => room.membership).thenReturn(matrix.Membership.invite);
    when(() => room.join()).thenAnswer((_) async {});
    when(
      () => room.getState('n42.token_gate'),
    ).thenAnswer((_) => raw == null ? null : state);
    when(() => state.content).thenAnswer((_) => raw!);
    when(
      () => wallet.getErc20Balance(
        contractAddress: any(named: 'contractAddress'),
        chainId: any(named: 'chainId'),
      ),
    ).thenAnswer((_) async => BigInt.from(100));
    when(
      () => wallet.getErc721Balance(
        contractAddress: any(named: 'contractAddress'),
        chainId: any(named: 'chainId'),
      ),
    ).thenAnswer((_) async => 100);
    when(
      () => wallet.getErc1155Balance(
        contractAddress: any(named: 'contractAddress'),
        tokenId: any(named: 'tokenId'),
        chainId: any(named: 'chainId'),
      ),
    ).thenAnswer((_) async => BigInt.from(100));
    when(() => wallet.getBalance(any())).thenAnswer((_) async => '1');
  });
  setUpAll(() => registerFallbackValue(BigInt.zero));

  test(
    'real invite Bloc checks balance once and joins after approval',
    () async {
      config([rule()]);
      final bloc = GroupBloc(repository);
      final outcome = bloc.stream.firstWhere(
        (s) => s.status == GroupStatus.success || s.status == GroupStatus.error,
      );
      bloc.add(const AcceptGroupInvite(roomId));
      final result = await outcome;
      expect(result.status, GroupStatus.success, reason: result.errorMessage);
      verify(
        () => wallet.getErc20Balance(contractAddress: contract, chainId: 1),
      ).called(1);
      verify(() => room.join()).called(1);
      await bloc.close();
    },
  );
  test(
    'real invite Bloc presents insufficient balance without joining',
    () async {
      config([rule(minimum: BigInt.from(101))]);
      final bloc = GroupBloc(repository);
      final outcome = bloc.stream.firstWhere(
        (s) =>
            s.status == GroupStatus.tokenGateVerified ||
            s.status == GroupStatus.error,
      );
      bloc.add(const AcceptGroupInvite(roomId));
      final result = await outcome;
      expect(
        result.status,
        GroupStatus.tokenGateVerified,
        reason: result.errorMessage,
      );
      expect(result.tokenGateResult?.passed, isFalse);
      expect(result.tokenGateRoomId, roomId);
      verifyNever(() => room.join());
      await bloc.close();
    },
  );
  test('absent gate requires no balance calls', () async {
    expect((await repository.verifyTokenGate(roomId)).passed, isTrue);
    verifyZeroInteractions(wallet);
  });
  test('disabled gate requires no balance calls', () async {
    raw = const TokenGateConfig().toJson();
    expect((await repository.verifyTokenGate(roomId)).passed, isTrue);
    verifyZeroInteractions(wallet);
  });
  test('enabled gate without a wallet fails', () async {
    config([rule()]);
    repository = GroupRepositoryImpl(source, manager);
    expect((await repository.verifyTokenGate(roomId)).passed, isFalse);
  });
  test('state read error cannot become an absent gate', () async {
    when(
      () => room.getState('n42.token_gate'),
    ).thenThrow(StateError('unavailable'));
    final result = await repository.verifyTokenGate(roomId);
    expect(result.passed, isFalse);
    expect(result.errorMessage, isNotEmpty);
    verifyZeroInteractions(wallet);
  });
  test('missing room cannot become an absent gate', () async {
    when(() => client.getRoomById(roomId)).thenReturn(null);
    expect((await repository.verifyTokenGate(roomId)).passed, isFalse);
    verifyZeroInteractions(wallet);
  });
  test('read failure blocks the actual accept-invite Bloc path', () async {
    when(
      () => room.getState('n42.token_gate'),
    ).thenThrow(StateError('unavailable'));
    final bloc = GroupBloc(repository);
    final outcome = bloc.stream.firstWhere(
      (s) => s.status == GroupStatus.error || s.status == GroupStatus.success,
    );
    bloc.add(const AcceptGroupInvite(roomId));
    final result = await outcome;
    expect(result.status, GroupStatus.error);
    verifyNever(() => room.join());
    await bloc.close();
  });

  final malformed = <String, void Function(Map<String, dynamic>)>{
    'invalid enabled flag': (v) => v['enabled'] = 'yes',
    'empty active rules': (v) => v['rules'] = <Object?>[],
    'invalid rules container': (v) => v['rules'] = 'invalid',
    'invalid rule entry': (v) => v['rules'] = <Object?>[null],
    'unknown operator': (v) => v['operator'] = 'xor',
    'invalid minimum': (v) =>
        (v['rules'] as List).first['min_balance'] = 'invalid',
    'negative minimum': (v) => (v['rules'] as List).first['min_balance'] = '-1',
    'unknown token standard': (v) =>
        (v['rules'] as List).first['token_standard'] = 'unknown',
    'invalid chain': (v) => (v['rules'] as List).first['chain_id'] = 0,
    'missing contract': (v) =>
        (v['rules'] as List).first['contract_address'] = null,
  };
  for (final entry in malformed.entries) {
    test('${entry.key} fails verification without reading balances', () async {
      config([rule()]);
      entry.value(raw!);
      final result = await repository.verifyTokenGate(roomId);
      expect(result.passed, isFalse);
      expect(result.errorMessage, isNotEmpty);
      verifyZeroInteractions(wallet);
    });
  }
  for (final standard in [
    TokenStandard.erc20,
    TokenStandard.erc721,
    TokenStandard.erc1155,
  ]) {
    for (final minimum in [100, 101]) {
      test(
        '${standard.name} compares the exact integer balance to $minimum',
        () async {
          config([rule(standard: standard, minimum: BigInt.from(minimum))]);
          final result = await repository.verifyTokenGate(roomId);
          expect(result.passed, minimum == 100);
          expect(result.ruleResults.single.actualBalance, BigInt.from(100));
        },
      );
    }
  }
  test('ERC-1155 reads the configured token ID and chain', () async {
    config([rule(standard: TokenStandard.erc1155, chainId: 137)]);
    await repository.verifyTokenGate(roomId);
    verify(
      () => wallet.getErc1155Balance(
        contractAddress: contract,
        tokenId: BigInt.from(7),
        chainId: 137,
      ),
    ).called(1);
  });
  for (final operator in GateOperator.values) {
    test(
      '${operator.name} aggregates all rules and retains individual failures',
      () async {
        config([
          rule(id: 'pass'),
          rule(id: 'fail', minimum: BigInt.from(101)),
        ], operator: operator);
        final result = await repository.verifyTokenGate(roomId);
        expect(result.passed, operator == GateOperator.or);
        expect(result.ruleResults.map((r) => r.passed), [true, false]);
      },
    );
  }
  test(
    'RPC failure is an explicit failed rule rather than zero-balance success',
    () async {
      config([rule(minimum: BigInt.zero)]);
      when(
        () => wallet.getErc20Balance(contractAddress: contract, chainId: 1),
      ).thenThrow(StateError('RPC unavailable'));
      final result = await repository.verifyTokenGate(roomId);
      expect(result.passed, isFalse);
      expect(
        result.ruleResults.single.errorMessage,
        contains('RPC unavailable'),
      );
    },
  );
  final balances = <String, String>{
    '0.000000000000000001': '1',
    '0.999999999999999999': '999999999999999999',
    '1.000000000000000001': '1000000000000000001',
    '123456789.123456789123456789': '123456789123456789123456789',
    ' 2.50 ': '2500000000000000000',
  };
  for (final entry in balances.entries) {
    test(
      'native amount ${entry.key.trim()} retains all smallest units',
      () async {
        final exact = BigInt.parse(entry.value);
        config([rule(standard: TokenStandard.native, minimum: exact)]);
        when(() => wallet.getBalance('ETH')).thenAnswer((_) async => entry.key);
        final result = await repository.verifyTokenGate(roomId);
        expect(result.passed, isTrue);
        expect(result.ruleResults.single.actualBalance, exact);
      },
    );
  }
  test(
    'native balance one smallest unit below the threshold is rejected',
    () async {
      config([
        rule(
          standard: TokenStandard.native,
          minimum: BigInt.parse('1000000000000000000'),
        ),
      ]);
      when(
        () => wallet.getBalance('ETH'),
      ).thenAnswer((_) async => '0.999999999999999999');
      expect((await repository.verifyTokenGate(roomId)).passed, isFalse);
    },
  );
  for (final value in [
    'invalid',
    '-1',
    'NaN',
    'Infinity',
    '0.0000000000000000001',
  ]) {
    test(
      'invalid native balance $value cannot satisfy a zero threshold',
      () async {
        config([rule(standard: TokenStandard.native, minimum: BigInt.zero)]);
        when(() => wallet.getBalance('ETH')).thenAnswer((_) async => value);
        final result = await repository.verifyTokenGate(roomId);
        expect(result.passed, isFalse);
        expect(result.ruleResults.single.errorMessage, isNotEmpty);
      },
    );
  }
  for (final entry in {
    10: 'OP',
    56: 'BNB',
    137: 'MATIC',
    42161: 'ARB',
  }.entries) {
    test('native chain ${entry.key} reads its own wallet asset', () async {
      config([rule(standard: TokenStandard.native, chainId: entry.key)]);
      expect((await repository.verifyTokenGate(roomId)).passed, isTrue);
      verify(() => wallet.getBalance(entry.value)).called(1);
    });
  }
  test(
    'unsupported native chain never falls back to Ethereum balance',
    () async {
      config([rule(standard: TokenStandard.native, chainId: 999999)]);
      expect((await repository.verifyTokenGate(roomId)).passed, isFalse);
      verifyNever(() => wallet.getBalance('ETH'));
    },
  );
  for (final tokenId in <String?>[null, '-1', 'invalid']) {
    test('invalid ERC-1155 token ID $tokenId fails before RPC', () async {
      config([rule(standard: TokenStandard.erc1155)]);
      (raw!['rules'] as List).first['token_id'] = tokenId;
      final result = await repository.verifyTokenGate(roomId);
      expect(result.passed, isFalse);
      expect(result.errorMessage, isNotEmpty);
      verifyZeroInteractions(wallet);
    });
  }
  test(
    'invalid save is surfaced through the settings Bloc without a state write',
    () async {
      final bloc = GroupBloc(repository);
      final outcome = bloc.stream.firstWhere(
        (s) => s.status == GroupStatus.error,
      );
      bloc.add(const SetTokenGate(roomId, TokenGateConfig(enabled: true)));
      final result = await outcome;
      expect(result.errorMessage, contains('Invalid token gate'));
      verifyZeroInteractions(client);
      await bloc.close();
    },
  );
  test('authorized gate save preserves the exact configuration', () async {
    final config = TokenGateConfig(
      enabled: true,
      rules: [rule()],
      operator: GateOperator.or,
      denialMessage: 'Members only',
    );
    when(() => room.canSendEvent('n42.token_gate')).thenReturn(true);
    when(
      () => client.setRoomStateWithKey(roomId, 'n42.token_gate', '', any()),
    ).thenAnswer((_) async => 'fixture-event');
    await repository.setTokenGate(roomId, config);
    verify(
      () => client.setRoomStateWithKey(
        roomId,
        'n42.token_gate',
        '',
        config.toJson(),
      ),
    ).called(1);
  });
  test('room permission denial prevents a gate state write', () async {
    when(() => room.canSendEvent('n42.token_gate')).thenReturn(false);
    when(() => client.userID).thenReturn('@me:test');
    when(() => room.getPowerLevelByUserId('@me:test')).thenReturn(0);
    await expectLater(
      repository.setTokenGate(
        roomId,
        TokenGateConfig(enabled: true, rules: [rule()]),
      ),
      throwsException,
    );
    verifyNever(
      () => client.setRoomStateWithKey(roomId, 'n42.token_gate', '', any()),
    );
  });
  test('disconnected Matrix client cannot verify an absent gate', () async {
    when(() => manager.client).thenReturn(null);
    final result = await repository.verifyTokenGate(roomId);
    expect(result.passed, isFalse);
    expect(result.errorMessage, isNotEmpty);
  });
}
