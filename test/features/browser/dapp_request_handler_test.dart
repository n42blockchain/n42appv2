// DAppRequestHandler 安全逻辑单元测试
//
// 覆盖范围：
// - 账户/链信息只读方法（eth_accounts / eth_chainId / net_version 等）
// - wallet_switchEthereumChain 的参数校验与链切换（含 isTest 走 chainId_test）
// - 签名类方法的安全闸门：eth_sign 全拒、地址不匹配拒绝、未审批默认拒绝(4001)
// - 未知方法拒绝（-32601，不盲目转发）
//
// 注意：所有断言都停在审批闸门之前或之时，绝不触发 _getPrivateKey /
// _getWeb3Client（那会访问未初始化的 globalProviderContainer 并触网）。
// 因此「抛出 4001/-32602」本身就证明了请求未进入取私钥/发交易环节。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/handler/dapp_request_handler.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

/// 钱包当前地址（混合大小写，用于验证地址比较不区分大小写）
const kWalletAddress = '0x1234567890AbcdEF1234567890aBcdef12345678';

/// 另一个地址，模拟 DApp 冒名声明的地址
const kOtherAddress = '0x9999999999999999999999999999999999999999';

/// 构造一个假的 EVM CoinModel（CoinModel 无参构造 + 公开字段直接赋值）
CoinModel makeEthModel({
  int chainId = 1,
  int? chainIdTest,
  bool isTest = false,
  String address = kWalletAddress,
}) {
  final cm = CoinModel();
  cm.coin = {'chainId': chainId, 'chainId_test': ?chainIdTest};
  cm.isTest = isTest;
  cm.address = address;
  return cm;
}

/// 匹配以 Map 形式抛出的 JSON-RPC 错误（{'code': x, 'message': y}）
Matcher throwsRpcError(int code) =>
    throwsA(isA<Map>().having((m) => m['code'], 'code', code));

void main() {
  group('账户与链信息只读方法', () {
    late DAppRequestHandler handler;

    setUp(() {
      handler = DAppRequestHandler(ethCoinModels: [makeEthModel(chainId: 1)]);
    });

    test('eth_accounts 返回当前钱包地址列表', () async {
      final result = await handler.handleRequest('eth_accounts', []);
      expect(result, [kWalletAddress]);
    });

    test('eth_requestAccounts 返回当前钱包地址列表', () async {
      final result = await handler.handleRequest('eth_requestAccounts', []);
      expect(result, [kWalletAddress]);
    });

    test('eth_chainId 返回十六进制链 ID 0x1', () async {
      final result = await handler.handleRequest('eth_chainId', []);
      expect(result, '0x1');
    });

    test('net_version 返回十进制链 ID 字符串 "1"', () async {
      final result = await handler.handleRequest('net_version', []);
      expect(result, '1');
    });

    test('eth_coinbase 返回当前钱包地址', () async {
      final result = await handler.handleRequest('eth_coinbase', []);
      expect(result, kWalletAddress);
    });
  });

  group('ethCoinModels 为空时的兜底行为', () {
    late DAppRequestHandler handler;

    setUp(() {
      handler = DAppRequestHandler(ethCoinModels: []);
    });

    test('chainIdHex 兜底为 0x1', () {
      expect(handler.chainIdHex, '0x1');
    });

    test('address 兜底为空字符串', () {
      expect(handler.address, '');
    });

    test('eth_accounts 返回 [""]（空地址）', () async {
      final result = await handler.handleRequest('eth_accounts', []);
      expect(result, ['']);
    });

    test('net_version 兜底为 "1"', () async {
      final result = await handler.handleRequest('net_version', []);
      expect(result, '1');
    });
  });

  group('wallet_switchEthereumChain 链切换', () {
    late DAppRequestHandler handler;

    setUp(() {
      // 三条链：ETH 主网 / Polygon / Sepolia（isTest，走 chainId_test）
      handler = DAppRequestHandler(
        ethCoinModels: [
          makeEthModel(chainId: 1),
          makeEthModel(chainId: 137),
          makeEthModel(chainId: 1, chainIdTest: 11155111, isTest: true),
        ],
      );
    });

    test('命中已知链后 selectedChainIndex 与 chainIdHex 变化，返回 null', () async {
      expect(handler.selectedChainIndex, 0);
      final result = await handler.handleRequest('wallet_switchEthereumChain', [
        {'chainId': '0x89'}, // 137
      ]);
      expect(result, isNull); // EIP-3326：成功返回 null
      expect(handler.selectedChainIndex, 1);
      expect(handler.chainIdHex, '0x89');
    });

    test('isTest=true 的链按 chainId_test 匹配（Sepolia 0xaa36a7）', () async {
      await handler.handleRequest('wallet_switchEthereumChain', [
        {'chainId': '0xaa36a7'}, // 11155111
      ]);
      expect(handler.selectedChainIndex, 2);
      expect(handler.chainIdHex, '0xaa36a7');
    });

    test('isTest=true 的链不响应其主网 chainId', () async {
      // 只保留 isTest 模型：它的 coin['chainId']=1，但匹配时应取 chainId_test，
      // 因此请求 0x1 不应命中，而是抛 4902
      final testOnly = DAppRequestHandler(
        ethCoinModels: [
          makeEthModel(chainId: 1, chainIdTest: 11155111, isTest: true),
        ],
      );
      expect(
        () => testOnly.handleRequest('wallet_switchEthereumChain', [
          {'chainId': '0x1'},
        ]),
        throwsRpcError(4902),
      );
    });

    test('参数非 Map 抛 -32602', () {
      expect(
        () => handler.handleRequest('wallet_switchEthereumChain', ['0x89']),
        throwsRpcError(-32602),
      );
    });

    test('chainId 非 String（数字）抛 -32602', () {
      expect(
        () => handler.handleRequest('wallet_switchEthereumChain', [
          {'chainId': 137},
        ]),
        throwsRpcError(-32602),
      );
    });

    test('chainId 非法 hex 抛 -32602', () {
      expect(
        () => handler.handleRequest('wallet_switchEthereumChain', [
          {'chainId': '0xzz'},
        ]),
        throwsRpcError(-32602),
      );
    });

    test('未知链抛 4902，selectedChainIndex 不变', () async {
      expect(
        () => handler.handleRequest('wallet_switchEthereumChain', [
          {'chainId': '0x2710'}, // 10000，不在列表
        ]),
        throwsRpcError(4902),
      );
      expect(handler.selectedChainIndex, 0);
    });

    test('大写前缀 0X89 与 0x89 等效（EIP-1193 hex quantity 大小写不敏感）', () async {
      // 修复后：剥前缀大小写不敏感，'0X89' 与 '0x89' 都解析为 137
      final result = await handler.handleRequest('wallet_switchEthereumChain', [
        {'chainId': '0X89'},
      ]);
      expect(result, isNull); // EIP-3326：成功返回 null
      expect(handler.selectedChainIndex, 1);
      expect(handler.chainIdHex, '0x89');
    });

    test('空 params 抛 -32602（invalid params，而非裸字符串→-32603）', () {
      expect(
        () => handler.handleRequest('wallet_switchEthereumChain', []),
        throwsRpcError(-32602),
      );
    });

    test('wallet_addEthereumChain 已知链等价于切换，未知链抛 4902', () async {
      final result = await handler.handleRequest('wallet_addEthereumChain', [
        {'chainId': '0x89'},
      ]);
      expect(result, isNull);
      expect(handler.selectedChainIndex, 1);

      expect(
        () => handler.handleRequest('wallet_addEthereumChain', [
          {'chainId': '0xdeadbeef'},
        ]),
        throwsRpcError(4902),
      );
    });
  });

  group('方法准入：eth_sign 拒绝与未知方法拒绝', () {
    late DAppRequestHandler handler;

    setUp(() {
      handler = DAppRequestHandler(ethCoinModels: [makeEthModel()]);
    });

    test('eth_sign 必须被拒绝（签任意数据的危险方法）', () {
      expect(
        () => handler.handleRequest('eth_sign', [kWalletAddress, '0xdead']),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('eth_sign is disabled for security'),
          ),
        ),
      );
    });

    test('即使设置了审批回调，eth_sign 依然被拒且不触发审批', () async {
      var approvalCalled = false;
      handler.onSigningRequest =
          ({
            required String origin,
            required String method,
            required Map<String, dynamic> details,
          }) async {
            approvalCalled = true;
            return true;
          };
      await expectLater(
        () => handler.handleRequest('eth_sign', [kWalletAddress, '0xdead']),
        throwsA(isA<Exception>()),
      );
      expect(approvalCalled, isFalse);
    });

    test('未知方法抛 -32601（不盲目转发到 RPC）', () {
      expect(
        () => handler.handleRequest('wallet_watchAsset', []),
        throwsRpcError(-32601),
      );
      expect(
        () => handler.handleRequest('evil_customMethod', []),
        throwsRpcError(-32601),
      );
    });
  });

  group('地址冒名防护：DApp 声明地址 != 钱包地址 → -32602 且不进审批', () {
    late DAppRequestHandler handler;
    late int approvalCallCount;

    setUp(() {
      handler = DAppRequestHandler(ethCoinModels: [makeEthModel()]);
      approvalCallCount = 0;
      handler.onSigningRequest =
          ({
            required String origin,
            required String method,
            required Map<String, dynamic> details,
          }) async {
            approvalCallCount++;
            return true; // 即使「用户同意」，也不应走到这一步
          };
    });

    test('personal_sign 地址不匹配', () async {
      await expectLater(
        () => handler.handleRequest('personal_sign', [
          '0xdeadbeef',
          kOtherAddress,
        ]),
        throwsRpcError(-32602),
      );
      expect(approvalCallCount, 0);
    });

    test('eth_signTypedData_v4 地址不匹配', () async {
      await expectLater(
        () => handler.handleRequest('eth_signTypedData_v4', [
          kOtherAddress,
          '{"types":{}}',
        ]),
        throwsRpcError(-32602),
      );
      expect(approvalCallCount, 0);
    });

    test('eth_sendTransaction from 不匹配', () async {
      await expectLater(
        () => handler.handleRequest('eth_sendTransaction', [
          <String, dynamic>{'from': kOtherAddress, 'to': kWalletAddress},
        ]),
        throwsRpcError(-32602),
      );
      expect(approvalCallCount, 0);
    });

    test('eth_signTransaction from 不匹配', () async {
      await expectLater(
        () => handler.handleRequest('eth_signTransaction', [
          <String, dynamic>{'from': kOtherAddress},
        ]),
        throwsRpcError(-32602),
      );
      expect(approvalCallCount, 0);
    });

    test('地址比较不区分大小写：全大写钱包地址可通过校验（止步于审批）', () async {
      // 用全大写形式声明同一地址：应通过地址校验、进入审批环节。
      // 审批回调此处未设置返回 false 场景——改用未审批 handler 验证：
      final noApproval = DAppRequestHandler(ethCoinModels: [makeEthModel()]);
      final upper = '0x${kWalletAddress.substring(2).toUpperCase()}';
      // 抛的是 4001（用户拒绝/无审批通道）而非 -32602（地址不匹配），
      // 证明大小写不同的同一地址通过了地址校验
      await expectLater(
        () => noApproval.handleRequest('personal_sign', ['0xdead', upper]),
        throwsRpcError(4001),
      );
    });
  });

  group('审批闸门：onSigningRequest 未设置 → 一律 4001 User rejected', () {
    late DAppRequestHandler handler;

    setUp(() {
      // 不设置 onSigningRequest —— _requestApproval 应默认返回 false
      handler = DAppRequestHandler(ethCoinModels: [makeEthModel()]);
    });

    // 敏感方法清单（对应 BrowserProvider._sensitiveMethods，私有无法直测，
    // 此处按行为逐一覆盖：全部需要用户审批，无审批通道时以 4001 终止，
    // 不触网、不取私钥）。eth_sign 在上方单独覆盖（直接拒绝）。
    final sensitiveCases = <String, List<dynamic>>{
      'personal_sign': ['0xdeadbeef', kWalletAddress],
      'eth_signTypedData': [kWalletAddress, '{"types":{}}'],
      'eth_signTypedData_v3': [kWalletAddress, '{"types":{}}'],
      'eth_signTypedData_v4': [kWalletAddress, '{"types":{}}'],
      'eth_sendTransaction': [
        <String, dynamic>{'from': kWalletAddress, 'to': kOtherAddress},
      ],
      'eth_signTransaction': [
        <String, dynamic>{'from': kWalletAddress},
      ],
    };

    for (final entry in sensitiveCases.entries) {
      test('${entry.key} 无审批通道 → 4001（不进入取私钥/触网环节）', () {
        // 若越过审批闸门，会先命中 globalProviderContainer 未初始化 /
        // 'Wallet service not available' 等错误而非 4001——
        // 因此 4001 断言本身就证明流程止步于审批
        expect(
          () => handler.handleRequest(entry.key, entry.value),
          throwsRpcError(4001),
        );
      });
    }

    test('用户明确拒绝（回调返回 false）→ 4001，回调恰被调用一次', () async {
      var callCount = 0;
      handler.onSigningRequest =
          ({
            required String origin,
            required String method,
            required Map<String, dynamic> details,
          }) async {
            callCount++;
            return false; // 用户点了拒绝
          };
      await expectLater(
        () => handler.handleRequest('personal_sign', [
          '0xdeadbeef',
          kWalletAddress,
        ]),
        throwsRpcError(4001),
      );
      expect(callCount, 1);
    });

    test('审批回调收到真实 DApp origin 与方法名', () async {
      String? seenOrigin;
      String? seenMethod;
      handler.dappOrigin = 'https://app.uniswap.org';
      handler.onSigningRequest =
          ({
            required String origin,
            required String method,
            required Map<String, dynamic> details,
          }) async {
            seenOrigin = origin;
            seenMethod = method;
            return false;
          };
      await expectLater(
        () => handler.handleRequest('personal_sign', [
          '0xdeadbeef',
          kWalletAddress,
        ]),
        throwsRpcError(4001),
      );
      expect(seenOrigin, 'https://app.uniswap.org');
      expect(seenMethod, 'personal_sign');
    });
  });
}
