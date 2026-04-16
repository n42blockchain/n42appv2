import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

/// Matrix服务器测试页面
///
/// 提供完整的服务器功能测试
class ServerTestPage extends StatefulWidget {
  const ServerTestPage({super.key});

  @override
  State<ServerTestPage> createState() => _ServerTestPageState();
}

class _ServerTestPageState extends State<ServerTestPage> {
  // 服务器配置
  static const String homeserver = 'https://m.si46.world';
  // 邀请码请向管理员获取
  static const String inviteCode = 'YOUR_INVITE_CODE_HERE';

  Client? _client;
  final List<TestResult> _testResults = [];
  bool _isRunning = false;
  String _currentTest = '';

  // 测试用户信息
  late String _testUsername;
  static const String _testPassword = 'TestPass123!@#';

  @override
  void initState() {
    super.initState();
    _testUsername =
        'n42_test_${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _cleanup() async {
    if (_client != null) {
      try {
        if (_client!.isLogged()) {
          await _client!.logout();
        }
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }
      await _client!.dispose();
      _client = null;
    }
  }

  Future<void> _runAllTests() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    try {
      // 1. 初始化客户端
      await _runTest('初始化客户端', _testInitClient);

      // 2. 连接服务器
      await _runTest('连接服务器', _testConnectServer);

      // 3. 获取服务器信息
      await _runTest('获取服务器信息', _testServerInfo);

      // 4. 获取登录流程
      await _runTest('获取登录流程', _testLoginFlows);

      // 5. 用户注册
      await _runTest('用户注册', _testRegister);

      // 6. 用户登录
      await _runTest('用户登录', _testLogin);

      // 7. 获取用户资料
      await _runTest('获取用户资料', _testGetProfile);

      // 8. 更新用户资料
      await _runTest('更新用户资料', _testUpdateProfile);

      // 9. 创建房间
      await _runTest('创建房间', _testCreateRoom);

      // 10. 发送消息
      await _runTest('发送消息', _testSendMessage);

      // 11. 同步消息
      await _runTest('同步消息', _testSync);

      // 12. 搜索用户
      await _runTest('搜索用户', _testSearchUsers);

      // 13. 登出
      await _runTest('用户登出', _testLogout);
    } catch (e) {
      _addResult('测试异常', false, e.toString());
    } finally {
      await _cleanup();
      setState(() {
        _isRunning = false;
        _currentTest = '';
      });
    }
  }

  Future<void> _runTest(String name, Future<void> Function() test) async {
    setState(() {
      _currentTest = name;
    });

    try {
      await test();
      _addResult(name, true, '成功');
    } catch (e) {
      _addResult(name, false, e.toString());
    }
  }

  void _addResult(String name, bool success, String message) {
    setState(() {
      _testResults.add(
        TestResult(name: name, success: success, message: message),
      );
    });
  }

  // ============================================
  // 测试用例
  // ============================================

  Future<void> _testInitClient() async {
    final tempDir = await getTemporaryDirectory();
    final sqfliteDb = await sqlite.openDatabase(
      p.join(tempDir.path, 'n42_chat_server_test_page.db'),
    );
    final database = await MatrixSdkDatabase.init(
      'N42ChatServerTest',
      database: sqfliteDb,
    );
    _client = Client('N42ChatServerTest', database: database);
  }

  Future<void> _testConnectServer() async {
    if (_client == null) throw Exception('客户端未初始化');

    final homeserverUri = Uri.parse(homeserver);
    await _client!.checkHomeserver(homeserverUri);

    if (_client!.homeserver == null) {
      throw Exception('服务器连接失败');
    }
  }

  Future<void> _testServerInfo() async {
    if (_client == null) throw Exception('客户端未初始化');

    try {
      final versions = await _client!.getVersions();
      debugPrint('服务器版本: ${versions.versions}');
    } catch (e) {
      debugPrint('获取服务器版本失败: $e');
      rethrow;
    }
  }

  Future<void> _testLoginFlows() async {
    if (_client == null) throw Exception('客户端未初始化');

    final flows = await _client!.getLoginFlows();
    if (flows == null || flows.isEmpty) {
      throw Exception('没有可用的登录方式');
    }

    debugPrint('支持的登录方式:');
    for (final flow in flows) {
      debugPrint('  - ${flow.type}');
    }
  }

  Future<void> _testRegister() async {
    if (_client == null) throw Exception('客户端未初始化');

    try {
      // 检查用户名是否可用
      try {
        final available = await _client!.checkUsernameAvailability(
          _testUsername,
        );
        if (available != true) {
          // 用户名不可用，生成新的
          _testUsername = 'n42_test_${Random().nextInt(99999)}';
        }
      } catch (e) {
        debugPrint('检查用户名可用性失败: $e');
      }

      // 尝试注册
      final result = await _client!.uiaRequestBackground(
        (auth) => _client!.register(
          username: _testUsername,
          password: _testPassword,
          initialDeviceDisplayName: 'N42 Chat Test Device',
          auth: auth,
        ),
      );

      debugPrint('注册成功: ${result.userId}');
    } catch (e) {
      // 如果注册需要邀请码或其他验证，可能会失败
      debugPrint('注册失败 (可能需要邀请码): $e');
      // 跳过注册，尝试直接登录
      rethrow;
    }
  }

  Future<void> _testLogin() async {
    if (_client == null) throw Exception('客户端未初始化');

    // 如果已经登录（注册后自动登录），跳过
    if (_client!.isLogged()) {
      debugPrint('已通过注册自动登录');
      return;
    }

    try {
      final result = await _client!.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: _testUsername),
        password: _testPassword,
        initialDeviceDisplayName: 'N42 Chat Test Device',
      );

      debugPrint('登录成功: ${result.userId}');
    } catch (e) {
      debugPrint('登录失败: $e');
      rethrow;
    }
  }

  Future<void> _testGetProfile() async {
    if (_client == null || !_client!.isLogged()) {
      throw Exception('未登录');
    }

    final profile = await _client!.getProfileFromUserId(_client!.userID!);
    debugPrint('用户资料:');
    debugPrint('  - 显示名称: ${profile.displayName}');
    debugPrint('  - 头像: ${profile.avatarUrl}');
  }

  Future<void> _testUpdateProfile() async {
    if (_client == null || !_client!.isLogged()) {
      throw Exception('未登录');
    }

    final newDisplayName =
        'N42 Test User ${DateTime.now().millisecondsSinceEpoch % 1000}';
    await _client!.request(
      RequestType.PUT,
      '/client/v3/profile/${Uri.encodeComponent(_client!.userID!)}/displayname',
      data: <String, Object?>{'displayname': newDisplayName},
    );
    debugPrint('更新显示名称为: $newDisplayName');
  }

  Future<void> _testCreateRoom() async {
    if (_client == null || !_client!.isLogged()) {
      throw Exception('未登录');
    }

    final roomId = await _client!.createRoom(
      name: 'N42 Test Room ${DateTime.now().millisecondsSinceEpoch % 1000}',
      topic: '这是一个测试房间',
      preset: CreateRoomPreset.privateChat,
    );

    debugPrint('创建房间成功: $roomId');
  }

  Future<void> _testSendMessage() async {
    if (_client == null || !_client!.isLogged()) {
      throw Exception('未登录');
    }

    // 先同步以获取房间列表
    await _client!.oneShotSync();

    final rooms = _client!.rooms;
    if (rooms.isEmpty) {
      throw Exception('没有可用的房间');
    }

    final room = rooms.first;
    final eventId = await room.sendTextEvent(
      '这是来自N42 Chat的测试消息 - ${DateTime.now()}',
    );

    debugPrint('发送消息成功: $eventId');
  }

  Future<void> _testSync() async {
    if (_client == null || !_client!.isLogged()) {
      throw Exception('未登录');
    }

    // 执行一次同步
    await _client!.oneShotSync();
    debugPrint('同步成功，房间数量: ${_client!.rooms.length}');
  }

  Future<void> _testSearchUsers() async {
    if (_client == null || !_client!.isLogged()) {
      throw Exception('未登录');
    }

    try {
      final result = await _client!.searchUserDirectory('test');
      debugPrint('搜索用户结果: ${result.results.length} 个用户');
      for (final user in result.results.take(5)) {
        debugPrint('  - ${user.userId}: ${user.displayName}');
      }
    } catch (e) {
      debugPrint('搜索用户失败 (可能不支持): $e');
      rethrow;
    }
  }

  Future<void> _testLogout() async {
    if (_client == null || !_client!.isLogged()) {
      debugPrint('未登录，跳过登出');
      return;
    }

    await _client!.logout();
    debugPrint('登出成功');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix服务器测试'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 服务器信息
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '服务器: $homeserver',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '测试用户: $_testUsername',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '邀请码: ${inviteCode.substring(0, 20)}...',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (_currentTest.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text('正在测试: $_currentTest'),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 测试结果列表
          Expanded(
            child: _testResults.isEmpty
                ? const Center(child: Text('点击下方按钮开始测试'))
                : ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      return ListTile(
                        leading: Icon(
                          result.success ? Icons.check_circle : Icons.error,
                          color: result.success ? Colors.green : Colors.red,
                        ),
                        title: Text(result.name),
                        subtitle: Text(
                          result.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: result.success ? Colors.grey : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 测试统计
          if (_testResults.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '总计',
                    _testResults.length.toString(),
                    Colors.blue,
                  ),
                  _buildStatItem(
                    '通过',
                    _testResults.where((r) => r.success).length.toString(),
                    Colors.green,
                  ),
                  _buildStatItem(
                    '失败',
                    _testResults.where((r) => !r.success).length.toString(),
                    Colors.red,
                  ),
                ],
              ),
            ),

          // 运行按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRunning ? null : _runAllTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isRunning ? '测试中...' : '运行全部测试'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

/// 测试结果
class TestResult {
  final String name;
  final bool success;
  final String message;

  TestResult({
    required this.name,
    required this.success,
    required this.message,
  });
}
