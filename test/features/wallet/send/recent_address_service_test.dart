import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // 每个测试前重置为空存储
    SharedPreferences.setMockInitialValues({});
  });

  test('users cannot read or clear each other history', () async {
    await RecentAddressService.save(
      'SUI',
      'alice-recipient',
      userUuid: 'alice',
    );
    await RecentAddressService.save('SUI', 'bob-recipient', userUuid: 'bob');
    expect(
      (await RecentAddressService.load(
        'SUI',
        userUuid: 'alice',
      )).single.address,
      'alice-recipient',
    );
    expect(
      (await RecentAddressService.load('SUI', userUuid: 'bob')).single.address,
      'bob-recipient',
    );
    await RecentAddressService.clear('SUI', userUuid: 'alice');
    expect(await RecentAddressService.load('SUI', userUuid: 'alice'), isEmpty);
    expect((await RecentAddressService.load('SUI', userUuid: 'bob')).length, 1);
  });
  test(
    'unattributed legacy history remains intact but is not assigned to a user',
    () async {
      const legacy =
          '{"SUI":[{"address":"private-old","time":"2026-01-01T00:00:00Z"}]}';
      SharedPreferences.setMockInitialValues({'recentSendAddresses': legacy});
      expect(
        await RecentAddressService.load('SUI', userUuid: 'alice'),
        isEmpty,
      );
      await RecentAddressService.save('SUI', 'new', userUuid: 'alice');
      expect(
        (await SharedPreferences.getInstance()).getString(
          'recentSendAddresses',
        ),
        legacy,
      );
    },
  );
  test('concurrent updates retain both chains and both owners', () async {
    await Future.wait([
      RecentAddressService.save('SUI', 'one', userUuid: 'alice'),
      RecentAddressService.save('ETH', 'two', userUuid: 'alice'),
      RecentAddressService.save('SUI', 'three', userUuid: 'bob'),
    ]);
    expect(
      (await RecentAddressService.load(
        'SUI',
        userUuid: 'alice',
      )).single.address,
      'one',
    );
    expect(
      (await RecentAddressService.load(
        'ETH',
        userUuid: 'alice',
      )).single.address,
      'two',
    );
    expect(
      (await RecentAddressService.load('SUI', userUuid: 'bob')).single.address,
      'three',
    );
  });

  group('RecentAddressEntry JSON round-trip', () {
    test('8. toJson + fromJson 数据无损（有 name）', () {
      final entry = RecentAddressEntry(
        address: '0xABCDEF1234567890',
        name: 'Alice',
        time: DateTime.utc(2026, 2, 20, 10, 0, 0),
      );
      final json = entry.toJson();
      final restored = RecentAddressEntry.fromJson(json);

      expect(restored.address, entry.address);
      expect(restored.name, entry.name);
      expect(restored.time, entry.time);
    });

    test('8. toJson + fromJson 数据无损（无 name）', () {
      final entry = RecentAddressEntry(
        address: 'So1abcxyz',
        name: null,
        time: DateTime.utc(2026, 2, 19, 8, 0, 0),
      );
      final json = entry.toJson();
      expect(json.containsKey('name'), isFalse); // name 缺省时不写入

      final restored = RecentAddressEntry.fromJson(json);
      expect(restored.address, entry.address);
      expect(restored.name, isNull);
      expect(restored.time, entry.time);
    });
  });

  group('RecentAddressService.save()', () {
    test('1. save() 将地址插入头部', () async {
      await RecentAddressService.save('ETH', '0xAddress1', userUuid: 'alice');
      await RecentAddressService.save('ETH', '0xAddress2', userUuid: 'alice');

      final list = await RecentAddressService.load(
        'ETH',
        maxCount: 5,
        userUuid: 'alice',
      );
      expect(list.first.address, '0xAddress2');
      expect(list[1].address, '0xAddress1');
    });

    test('2. save() 对同一地址去重（更新时间，移到头部）', () async {
      await RecentAddressService.save('ETH', '0xAddress1', userUuid: 'alice');
      await RecentAddressService.save('ETH', '0xAddress2', userUuid: 'alice');
      await RecentAddressService.save(
        'ETH',
        '0xAddress1',
        userUuid: 'alice',
      ); // 重复地址

      final list = await RecentAddressService.load(
        'ETH',
        maxCount: 5,
        userUuid: 'alice',
      );
      // 0xAddress1 应在头部，且只出现一次
      expect(list.length, 2);
      expect(list.first.address, '0xAddress1');
    });

    test('2. save() 去重不区分大小写', () async {
      await RecentAddressService.save('ETH', '0xAbCdEf', userUuid: 'alice');
      await RecentAddressService.save(
        'ETH',
        '0xabcdef',
        userUuid: 'alice',
      ); // 大小写不同但相同地址

      final list = await RecentAddressService.load(
        'ETH',
        maxCount: 5,
        userUuid: 'alice',
      );
      expect(list.length, 1);
    });

    test('3. save() 截断至 10 条上限', () async {
      for (int i = 1; i <= 12; i++) {
        await RecentAddressService.save(
          'ETH',
          '0xAddress$i',
          userUuid: 'alice',
        );
      }
      final list = await RecentAddressService.load(
        'ETH',
        maxCount: 20,
        userUuid: 'alice',
      );
      expect(list.length, 10);
    });
  });

  group('RecentAddressService.load()', () {
    test('4. load() 按时间倒序返回（最新在前）', () async {
      await RecentAddressService.save('ETH', '0xOldest', userUuid: 'alice');
      await RecentAddressService.save('ETH', '0xMiddle', userUuid: 'alice');
      await RecentAddressService.save('ETH', '0xNewest', userUuid: 'alice');

      final list = await RecentAddressService.load(
        'ETH',
        maxCount: 5,
        userUuid: 'alice',
      );
      expect(list[0].address, '0xNewest');
      expect(list[1].address, '0xMiddle');
      expect(list[2].address, '0xOldest');
    });

    test('5. load(maxCount: 3) 只返回 3 条', () async {
      for (int i = 1; i <= 6; i++) {
        await RecentAddressService.save('ETH', '0xAddr$i', userUuid: 'alice');
      }
      final list = await RecentAddressService.load(
        'ETH',
        maxCount: 3,
        userUuid: 'alice',
      );
      expect(list.length, 3);
    });

    test('4. 空历史返回空列表', () async {
      final list = await RecentAddressService.load('ETH', userUuid: 'alice');
      expect(list, isEmpty);
    });
  });

  group('RecentAddressService.clear()', () {
    test('6. clear() 清空指定链历史，其他链不受影响', () async {
      await RecentAddressService.save('ETH', '0xEthAddr', userUuid: 'alice');
      await RecentAddressService.save('SOL', 'SolAddr1', userUuid: 'alice');

      await RecentAddressService.clear('ETH', userUuid: 'alice');

      final ethList = await RecentAddressService.load('ETH', userUuid: 'alice');
      final solList = await RecentAddressService.load('SOL', userUuid: 'alice');

      expect(ethList, isEmpty);
      expect(solList.length, 1);
    });
  });

  group('多链数据独立性', () {
    test('7. ETH 和 SOL 各有各的历史，互不干扰', () async {
      await RecentAddressService.save('ETH', '0xEth1', userUuid: 'alice');
      await RecentAddressService.save('ETH', '0xEth2', userUuid: 'alice');
      await RecentAddressService.save('SOL', 'Sol1', userUuid: 'alice');

      final ethList = await RecentAddressService.load(
        'ETH',
        maxCount: 5,
        userUuid: 'alice',
      );
      final solList = await RecentAddressService.load(
        'SOL',
        maxCount: 5,
        userUuid: 'alice',
      );

      expect(ethList.length, 2);
      expect(ethList.every((e) => e.address.startsWith('0x')), isTrue);
      expect(solList.length, 1);
      expect(solList.first.address, 'Sol1');
    });
  });
}
