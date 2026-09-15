// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// ATOM / SOL 质押交易构建器纯函数测试（不触网）。
//
// 覆盖 lib/features/staking/api/atom_staking_api.dart 383-452 行的
// buildDelegateMessage / buildUndelegateMessage / buildClaimRewardsMessage /
// buildRedelegateMessage，以及 lib/features/staking/api/sol_staking_api.dart
// 263-315 行的 buildStakeTransaction / buildUnstakeTransaction /
// buildWithdrawTransaction。这些方法只做本地 map 组装，不发任何请求。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/staking/api/atom_staking_api.dart';
import 'package:n42_wallet/features/staking/api/sol_staking_api.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

void main() {
  group('AtomStakingApi 交易消息构建', () {
    final api = AtomStakingApi();
    const delegator = 'cosmos1qypqxpq9qcrsszg2pvxq6rs0zqg3yyc5lzv7xu';
    const validator = 'cosmosvaloper1sjllsnramtg3ewxqwwrwjxfgc4n4ef9u2lcnj0';
    const validator2 = 'cosmosvaloper156gqf9837u7d4c4678yt3rl4ls9c5vuursrrzf';

    /// 从 MessageModel 中取出唯一一条 message map
    Map<String, dynamic> singleMessage(MessageModel mm) {
      final resp = mm.data as StakingTransactionResponse;
      final messages = resp.txData!['messages'] as List;
      expect(messages, hasLength(1), reason: 'messages 应恰好包含 1 条');
      return messages.first as Map<String, dynamic>;
    }

    test('buildDelegateMessage：@type 精确匹配、denom=uatom、success=true', () async {
      final mm = await api.buildDelegateMessage(
        delegatorAddress: delegator,
        validatorAddress: validator,
        amount: BigInt.from(1000000),
      );

      expect(mm.error, isFalse);
      final resp = mm.data as StakingTransactionResponse;
      expect(resp.success, isTrue);
      expect(resp.txHash, ''); // 本地构建阶段尚无 txHash

      final msg = singleMessage(mm);
      expect(msg['@type'], '/cosmos.staking.v1beta1.MsgDelegate');
      expect(msg['delegator_address'], delegator);
      expect(msg['validator_address'], validator);
      expect(msg['amount'], {'denom': 'uatom', 'amount': '1000000'});
    });

    test('buildUndelegateMessage：@type 精确匹配、denom=uatom', () async {
      final mm = await api.buildUndelegateMessage(
        delegatorAddress: delegator,
        validatorAddress: validator,
        amount: BigInt.from(42),
      );

      expect(mm.error, isFalse);
      expect((mm.data as StakingTransactionResponse).success, isTrue);

      final msg = singleMessage(mm);
      expect(msg['@type'], '/cosmos.staking.v1beta1.MsgUndelegate');
      expect(msg['delegator_address'], delegator);
      expect(msg['validator_address'], validator);
      expect((msg['amount'] as Map)['denom'], 'uatom');
      expect((msg['amount'] as Map)['amount'], '42');
    });

    test('buildClaimRewardsMessage：@type 精确匹配、不含 amount 字段', () async {
      final mm = await api.buildClaimRewardsMessage(
        delegatorAddress: delegator,
        validatorAddress: validator,
      );

      expect(mm.error, isFalse);
      expect((mm.data as StakingTransactionResponse).success, isTrue);

      final msg = singleMessage(mm);
      expect(
        msg['@type'],
        '/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward',
      );
      expect(msg['delegator_address'], delegator);
      expect(msg['validator_address'], validator);
      // 领取奖励消息不带金额
      expect(msg.containsKey('amount'), isFalse);
    });

    test('buildRedelegateMessage：src/dst 顺序不可颠倒', () async {
      final mm = await api.buildRedelegateMessage(
        delegatorAddress: delegator,
        srcValidatorAddress: validator,
        dstValidatorAddress: validator2,
        amount: BigInt.from(7),
      );

      expect(mm.error, isFalse);
      expect((mm.data as StakingTransactionResponse).success, isTrue);

      final msg = singleMessage(mm);
      expect(msg['@type'], '/cosmos.staking.v1beta1.MsgBeginRedelegate');
      // src 必须落在 validator_src_address，dst 必须落在 validator_dst_address
      expect(msg['validator_src_address'], validator);
      expect(msg['validator_dst_address'], validator2);
      expect(msg['delegator_address'], delegator);
      expect(msg['amount'], {'denom': 'uatom', 'amount': '7'});
    });

    test('超大 BigInt（>2^63）金额经 toString 序列化无精度损失', () async {
      // 2^80 + 1，远超 int64 可表示范围，若中途转 double/int 必然失真
      final huge = (BigInt.one << 80) + BigInt.one;
      expect(huge.toString(), '1208925819614629174706177');

      final mm = await api.buildDelegateMessage(
        delegatorAddress: delegator,
        validatorAddress: validator,
        amount: huge,
      );

      final msg =
          (mm.data as StakingTransactionResponse).txData!['messages'][0]
              as Map<String, dynamic>;
      expect((msg['amount'] as Map)['amount'], '1208925819614629174706177');
    });

    test('金额为 0 的边界：序列化为字符串 "0"', () async {
      final mm = await api.buildUndelegateMessage(
        delegatorAddress: delegator,
        validatorAddress: validator,
        amount: BigInt.zero,
      );

      final msg =
          (mm.data as StakingTransactionResponse).txData!['messages'][0]
              as Map<String, dynamic>;
      expect((msg['amount'] as Map)['amount'], '0');
    });
  });

  group('SolStakingApi 交易构建', () {
    final api = SolStakingApi();
    const from = 'FromAddr1111111111111111111111111111111111';
    const validator = 'Vote111111111111111111111111111111111111111';
    const stakeAccount = 'StakeAcct111111111111111111111111111111111';
    const to = 'ToAddr111111111111111111111111111111111111';
    // Solana 官方 Stake Program 常量（源码中的 _stakeProgramId 私有常量）
    const expectedStakeProgramId =
        'Stake11111111111111111111111111111111111111';

    test('buildStakeTransaction：type=stake、携带 stakeProgramId 常量', () async {
      final mm = await api.buildStakeTransaction(
        fromAddress: from,
        validatorAddress: validator,
        amount: BigInt.from(2000000000),
      );

      // 现状断言：MessageModel() 默认 error=false（_buildTxResponse 未显式改动）
      expect(mm.error, isFalse);
      final resp = mm.data as StakingTransactionResponse;
      expect(resp.success, isTrue);
      expect(resp.error, isNull);
      expect(resp.txHash, '');

      final txData = resp.txData!;
      expect(txData['type'], 'stake');
      expect(txData['from'], from);
      expect(txData['validator'], validator);
      expect(txData['amount'], '2000000000');
      expect(txData['stakeProgramId'], expectedStakeProgramId);
    });

    test('buildUnstakeTransaction：type=deactivate、无 amount 字段', () async {
      final mm = await api.buildUnstakeTransaction(
        stakeAccountAddress: stakeAccount,
        fromAddress: from,
      );

      expect(mm.error, isFalse);
      final resp = mm.data as StakingTransactionResponse;
      expect(resp.success, isTrue);
      expect(resp.error, isNull);

      final txData = resp.txData!;
      expect(txData['type'], 'deactivate');
      expect(txData['stakeAccount'], stakeAccount);
      expect(txData['authority'], from);
      expect(txData['stakeProgramId'], expectedStakeProgramId);
      expect(txData.containsKey('amount'), isFalse);
    });

    test('buildWithdrawTransaction：type=withdraw、amount 字符串保精度', () async {
      // lamports 级超大金额，>2^63，验证 BigInt.toString 全程保真
      final huge = BigInt.parse('92233720368547758080000'); // 2^63 * 10000
      final mm = await api.buildWithdrawTransaction(
        stakeAccountAddress: stakeAccount,
        toAddress: to,
        amount: huge,
      );

      expect(mm.error, isFalse);
      final resp = mm.data as StakingTransactionResponse;
      expect(resp.success, isTrue);

      final txData = resp.txData!;
      expect(txData['type'], 'withdraw');
      expect(txData['stakeAccount'], stakeAccount);
      expect(txData['to'], to);
      expect(txData['amount'], '92233720368547758080000');
      expect(txData['stakeProgramId'], expectedStakeProgramId);
    });
  });
}
