#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:matrix/matrix.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Matrix服务器集成测试脚本
///
/// 服务器: https://m.si46.world/
/// 邀请码: c321fb4d6ce5e93984452cbd11427f5dfc8c02a2c728234ce8d6e5ce317e9a81
///
/// 运行方式:
///   cd n42_chat
///   dart run tool/server_test.dart

void main() async {
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║           N42 Chat Matrix Server Integration Test            ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');

  const homeserver = 'https://m.si46.world';
  // 邀请码请向管理员获取
  const inviteCode = 'YOUR_INVITE_CODE_HERE';

  // 测试用户
  final testUsername = 'n42test${Random().nextInt(99999)}';
  const testPassword = 'N42TestPass123!@#';

  print('📡 服务器: $homeserver');
  print('🔑 邀请码: ${inviteCode.substring(0, 20)}...');
  print('👤 测试用户: $testUsername');
  print('');
  print('═══════════════════════════════════════════════════════════════');
  print('');

  sqfliteFfiInit();
  final sqfliteDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  final database = await MatrixSdkDatabase.init(
    'N42ChatCLITest',
    database: sqfliteDb,
    sqfliteFactory: databaseFactoryFfi,
  );
  final client = Client('N42ChatCLITest', database: database);

  int passed = 0;
  int failed = 0;

  Future<bool> runTest(String name, Future<void> Function() test) async {
    stdout.write('🔄 $name... ');
    try {
      await test();
      print('✅ 通过');
      passed++;
      return true;
    } catch (e) {
      print('❌ 失败');
      print('   错误: $e');
      failed++;
      return false;
    }
  }

  try {
    // 1. 连接服务器
    await runTest('连接服务器', () async {
      await client.checkHomeserver(Uri.parse(homeserver));
      if (client.homeserver == null) {
        throw Exception('服务器连接失败');
      }
    });

    // 2. 获取服务器版本
    await runTest('获取服务器版本', () async {
      final versions = await client.getVersions();
      print('\n   版本: ${versions.versions.join(", ")}');
    });

    // 3. 获取登录流程
    await runTest('获取登录流程', () async {
      final flows = await client.getLoginFlows();
      if (flows == null || flows.isEmpty) {
        throw Exception('没有可用的登录方式');
      }
      print('\n   登录方式: ${flows.map((f) => f.type).join(", ")}');
    });

    // 4. 检查用户名可用性
    bool usernameAvailable = false;
    await runTest('检查用户名可用性', () async {
      try {
        final result = await client.checkUsernameAvailability(testUsername);
        usernameAvailable = result == true;
      } catch (e) {
        // 有些服务器可能不支持用户名检查
        usernameAvailable = true;
      }
      print('\n   用户名 $testUsername ${usernameAvailable ? "可用" : "不可用"}');
    });

    // 5. 注册用户
    if (usernameAvailable) {
      await runTest('注册新用户', () async {
        try {
          final result = await client.uiaRequestBackground(
            (auth) => client.register(
              username: testUsername,
              password: testPassword,
              initialDeviceDisplayName: 'N42 CLI Test',
              auth: auth,
            ),
          );
          print('\n   用户ID: ${result.userId}');
        } catch (e) {
          if (e.toString().contains('Registration') ||
              e.toString().contains('flows') ||
              e.toString().contains('M_FORBIDDEN')) {
            print('\n   注册需要额外验证 (可能需要邀请码)');
            rethrow;
          }
          rethrow;
        }
      });
    }

    // 6. 登录
    if (!client.isLogged()) {
      await runTest('用户登录', () async {
        // 尝试使用测试账号登录
        final result = await client.login(
          LoginType.mLoginPassword,
          identifier: AuthenticationUserIdentifier(user: testUsername),
          password: testPassword,
          initialDeviceDisplayName: 'N42 CLI Test',
        );
        print('\n   登录成功: ${result.userId}');
      });
    }

    if (client.isLogged()) {
      // 7. 获取用户资料
      await runTest('获取用户资料', () async {
        final profile = await client.getProfileFromUserId(client.userID!);
        print('\n   显示名称: ${profile.displayName ?? "未设置"}');
        print('   头像: ${profile.avatarUrl ?? "未设置"}');
      });

      // 8. 更新用户资料
      await runTest('更新用户资料', () async {
        final newName =
            'N42 Test ${DateTime.now().millisecondsSinceEpoch % 1000}';
        await client.request(
          RequestType.PUT,
          '/client/v3/profile/${Uri.encodeComponent(client.userID!)}/displayname',
          data: <String, Object?>{'displayname': newName},
        );
        print('\n   新名称: $newName');
      });

      // 9. 同步
      await runTest('消息同步', () async {
        await client.oneShotSync();
        print('\n   房间数量: ${client.rooms.length}');
      });

      // 10. 创建房间
      String? newRoomId;
      await runTest('创建测试房间', () async {
        newRoomId = await client.createRoom(
          name: 'N42 Test Room',
          topic: '这是N42 Chat自动化测试创建的房间',
          preset: CreateRoomPreset.privateChat,
        );
        print('\n   房间ID: $newRoomId');
      });

      // 11. 发送消息
      if (newRoomId != null) {
        await runTest('发送测试消息', () async {
          await client.oneShotSync();
          final room = client.getRoomById(newRoomId!);
          if (room == null) throw Exception('房间不存在');
          final eventId = await room.sendTextEvent(
            '这是来自N42 Chat CLI测试的消息 - ${DateTime.now()}',
          );
          print('\n   消息ID: $eventId');
        });
      }

      // 12. 搜索用户
      await runTest('搜索用户', () async {
        try {
          final result = await client.searchUserDirectory('test', limit: 5);
          print('\n   找到 ${result.results.length} 个用户');
          for (final user in result.results.take(3)) {
            print('   - ${user.userId}');
          }
        } catch (e) {
          print('\n   用户搜索可能被禁用');
          rethrow;
        }
      });

      // 13. 获取公共房间
      await runTest('获取公共房间', () async {
        try {
          final result = await client.queryPublicRooms(limit: 5);
          print('\n   找到 ${result.chunk.length} 个公共房间');
          for (final room in result.chunk.take(3)) {
            print('   - ${room.name ?? room.roomId}');
          }
        } catch (e) {
          print('\n   公共房间列表可能被禁用');
          rethrow;
        }
      });

      // 14. 登出
      await runTest('用户登出', () async {
        await client.logout();
      });
    }
  } catch (e) {
    print('');
    print('⚠️ 测试过程中发生异常: $e');
  } finally {
    await client.dispose();
  }

  // 输出结果
  print('');
  print('═══════════════════════════════════════════════════════════════');
  print('');
  print('📊 测试结果汇总:');
  print('   ✅ 通过: $passed');
  print('   ❌ 失败: $failed');
  final total = passed + failed;
  if (total > 0) {
    print('   📈 通过率: ${(passed / total * 100).toStringAsFixed(1)}%');
  }
  print('');

  if (failed > 0) {
    print('⚠️ 部分测试失败，请检查服务器配置或网络连接');
    exit(1);
  } else {
    print('🎉 所有测试通过！');
    exit(0);
  }
}
