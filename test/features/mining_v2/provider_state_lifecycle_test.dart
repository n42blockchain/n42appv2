// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// MiningV2Provider 状态生命周期测试。
//
// 覆盖 lib/features/mining_v2/provider/mining_v2_provider_state.dart：
//   - resetData（114-122 行）：换钱包时必须清掉 _mining/_web3 惰性缓存，
//     否则新钱包会复用旧私钥构建的 web3 客户端（资金安全问题）。
//   - disposeState（124-137 行）：幂等，Timer 全 null 或已清理时连调不抛。
// 不触网：MiningApi.init() 仅构造 MethodChannel 包装，MiningWeb3.init()
// 仅本地解码私钥，均不发起 platform channel 调用或网络请求。

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// 生成一个合法的 base64 编码 32 字节私钥（MiningWeb3.init 的输入格式）
String fakePrivateKey(int seed) {
  return base64Encode(List<int>.generate(32, (i) => (i + seed) % 255 + 1));
}

void main() {
  group('resetData 清缓存', () {
    test('resetData 前 web3/mining getter 返回同一缓存实例', () {
      final p = MiningV2Provider();
      p.privateKey = fakePrivateKey(1);

      expect(identical(p.web3, p.web3), isTrue, reason: 'web3 应惰性缓存');
      expect(identical(p.mining, p.mining), isTrue, reason: 'mining 应惰性缓存');
    });

    test('resetData 后 web3/mining 缓存被清，重新访问得到新实例', () {
      final p = MiningV2Provider();
      p.privateKey = fakePrivateKey(1);
      final web3Before = p.web3;
      final miningBefore = p.mining;

      p.resetData();

      expect(
        identical(p.web3, web3Before),
        isFalse,
        reason: 'resetData 后 web3 必须重建，不能复用旧私钥客户端',
      );
      expect(identical(p.mining, miningBefore), isFalse);
    });

    test('换钱包场景：reset 后新私钥生效，不复用旧私钥的 credentials', () {
      final p = MiningV2Provider();
      p.privateKey = fakePrivateKey(1);
      final oldAddress = p.web3.credentials?.address;

      // 模拟切换钱包：resetData + 换新私钥
      p.resetData();
      p.privateKey = fakePrivateKey(100);
      final newAddress = p.web3.credentials?.address;

      expect(oldAddress, isNotNull);
      expect(newAddress, isNotNull);
      expect(newAddress, isNot(equals(oldAddress)),
          reason: '新 web3 客户端必须由新私钥派生地址');
    });

    test('resetData 重置基础字段并通知监听者', () {
      final p = MiningV2Provider();
      p.depositsEnable = true;
      p.miningStatus = true;
      p.walletName = 'wallet-A';
      p.address = '0xdead';

      var notified = 0;
      p.addListener(() => notified++);
      p.resetData();

      expect(p.depositsEnable, isFalse);
      expect(p.miningStatus, isFalse);
      expect(p.walletName, '');
      expect(p.address, isNull);
      expect(notified, 1);
    });
  });

  group('disposeState 幂等性', () {
    test('Timer 全 null 时调用不抛', () {
      final p = MiningV2Provider();
      expect(() => p.disposeState(), returnsNormally);
    });

    test('连续调用两次不抛', () {
      final p = MiningV2Provider();
      expect(() {
        p.disposeState();
        p.disposeState();
      }, returnsNormally);
    });

    test('已设置的 Timer 被全部取消并置 null', () {
      final p = MiningV2Provider();
      // 直接注入哑 Timer，避免走会触网/轮询的 start* 方法
      final t1 = Timer(const Duration(days: 1), () {});
      final t2 = Timer(const Duration(days: 1), () {});
      final t3 = Timer(const Duration(days: 1), () {});
      final t4 = Timer(const Duration(days: 1), () {});
      final t5 = Timer(const Duration(days: 1), () {});
      p.txCheckTimer = t1;
      p.withdrawalTimer = t2;
      p.beaconValidatorTimer = t3;
      p.statusPollTimer = t4;
      p.wsReconnectTimer = t5;

      p.disposeState();

      expect(t1.isActive, isFalse);
      expect(t2.isActive, isFalse);
      expect(t3.isActive, isFalse);
      expect(t4.isActive, isFalse);
      expect(t5.isActive, isFalse);
      expect(p.txCheckTimer, isNull);
      expect(p.withdrawalTimer, isNull);
      expect(p.beaconValidatorTimer, isNull);
      expect(p.statusPollTimer, isNull);
      expect(p.wsReconnectTimer, isNull);

      // 清理后再调一次仍安全（幂等）
      expect(() => p.disposeState(), returnsNormally);
    });
  });
}
