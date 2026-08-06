// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// MiningV2Provider.getBeaconValidator 对 rmm.data 为 null 的防御测试。
//
// 覆盖 lib/features/mining_v2/provider/mining_v2_provider_beacon.dart：
// JSON-RPC result 为 null 时 MiningApi._postBeacon 返回 error=false 且
// data=null（历史缺陷：函数前半段用 data?[...] null 安全访问，而
// activation_timestamp / exit_timestamp 直接下标，抛 NoSuchMethodError）。
// 通过 debugMiningApi 注入替身 MiningApi，不触网。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// 返回固定 MessageModel 的 MiningApi 替身
class _FakeMiningApi extends MiningApi {
  _FakeMiningApi(this.result) : super.init();
  final MessageModel result;

  @override
  Future<MessageModel> getBeaconValidator(String pubKey) async => result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // 代码路径会读 S.current.g_mining_key_84 等文案
    await S.load(const Locale('en'));
  });

  MiningV2Provider buildProvider(MessageModel rmm) {
    final p = MiningV2Provider();
    p.miningKeypart = {'publicKey': '0xabc123'};
    p.debugMiningApi = _FakeMiningApi(rmm);
    return p;
  }

  test('error=false 且 data=null：不抛异常，按 timestamp=0 语义处理', () async {
    final p = buildProvider(MessageModel()..data = null);

    // 修复前此处抛 NoSuchMethodError（data['activation_timestamp']）
    await p.getBeaconValidator();

    expect(p.activationTime, isNull);
    expect(p.showRedemption, isFalse, reason: 'activation_timestamp 缺失按未激活处理');
    expect(p.exitTimestamp, 0);
    expect(p.showRedemption2, isTrue, reason: 'exit_timestamp 缺失按未退出处理');

    // 清理 starBeaconValidatorTimer 挂起的定时器
    p.disposeState();
  });

  test('data 为空 Map（字段缺失）：同样按 0 兜底，不抛异常', () async {
    final p = buildProvider(MessageModel()..data = {});

    await p.getBeaconValidator();

    expect(p.activationTime, isNull);
    expect(p.exitTimestamp, 0);

    p.disposeState();
  });

  test('data 携带真实 activation_timestamp：null 安全访问不影响正常解析', () async {
    // 激活时间在一个挖矿周期（128s）之前 → 激活期已满，showRedemption=true
    final activatedAt =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - kMiningCycleSeconds * 2;
    final p = buildProvider(
      MessageModel()
        ..data = {
          'balance_in_beacon': 0,
          'inactivity_score': 0,
          'activation_timestamp': activatedAt,
          'exit_timestamp': 0,
        },
    );

    await p.getBeaconValidator();

    expect(
      p.activationTime,
      DateTime.fromMillisecondsSinceEpoch(activatedAt * 1000),
    );
    expect(p.showRedemption, isTrue);
    expect(p.showRedemption2, isTrue);

    p.disposeState();
  });

  test('error=true 时不进入解析逻辑，状态保持初始值', () async {
    final p = buildProvider(MessageModel.error()..data = 'boom');

    await p.getBeaconValidator();

    expect(p.activationTime, isNull);
    expect(p.showRedemption, isFalse);
    expect(p.showRedemption2, isFalse);

    p.disposeState();
  });
}
