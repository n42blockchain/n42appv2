// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/wallet/pages/network/custom_chain_service.dart';

/// 热门 EVM 链快速添加预设 —— Wallet Roadmap S5。
///
/// 提供一批主流但非内置的 EVM 链（规范公共 RPC），用户一键添加。添加仍走
/// [CustomChainService.addChain]（会用 eth_chainId 校验 RPC），故预设 RPC 失效
/// 时会被安全拒绝。对标 Bitget/OKX 的多链广度。
class PopularChainPresets {
  PopularChainPresets._();

  /// 全部预设（不含内置链）。每次调用新建对象（addedAt 取当下）。
  static List<CustomChain> all() => [
        CustomChain(
          chainId: 534352,
          name: 'Scroll',
          rpcUrl: 'https://rpc.scroll.io',
          symbol: 'ETH',
          explorerUrl: 'https://scrollscan.com',
        ),
        CustomChain(
          chainId: 81457,
          name: 'Blast',
          rpcUrl: 'https://rpc.blast.io',
          symbol: 'ETH',
          explorerUrl: 'https://blastscan.io',
        ),
        CustomChain(
          chainId: 5000,
          name: 'Mantle',
          rpcUrl: 'https://rpc.mantle.xyz',
          symbol: 'MNT',
          explorerUrl: 'https://explorer.mantle.xyz',
        ),
        CustomChain(
          chainId: 34443,
          name: 'Mode',
          rpcUrl: 'https://mainnet.mode.network',
          symbol: 'ETH',
          explorerUrl: 'https://explorer.mode.network',
        ),
        CustomChain(
          chainId: 100,
          name: 'Gnosis',
          rpcUrl: 'https://rpc.gnosischain.com',
          symbol: 'XDAI',
          explorerUrl: 'https://gnosisscan.io',
        ),
        CustomChain(
          chainId: 42220,
          name: 'Celo',
          rpcUrl: 'https://forno.celo.org',
          symbol: 'CELO',
          explorerUrl: 'https://celoscan.io',
        ),
        CustomChain(
          chainId: 1101,
          name: 'Polygon zkEVM',
          rpcUrl: 'https://zkevm-rpc.com',
          symbol: 'ETH',
          explorerUrl: 'https://zkevm.polygonscan.com',
        ),
        CustomChain(
          chainId: 1088,
          name: 'Metis',
          rpcUrl: 'https://andromeda.metis.io/?owner=1088',
          symbol: 'METIS',
          explorerUrl: 'https://explorer.metis.io',
        ),
        CustomChain(
          chainId: 25,
          name: 'Cronos',
          rpcUrl: 'https://evm.cronos.org',
          symbol: 'CRO',
          explorerUrl: 'https://cronoscan.com',
        ),
        CustomChain(
          chainId: 250,
          name: 'Fantom',
          rpcUrl: 'https://rpc.ftm.tools',
          symbol: 'FTM',
          explorerUrl: 'https://ftmscan.com',
        ),
      ];

  /// 过滤掉内置链与已添加链（[existingChainIds]），返回可一键添加的预设。
  static List<CustomChain> available(List<int> existingChainIds) {
    final existing = existingChainIds.toSet();
    return all()
        .where((c) =>
            !CustomChainService.builtInChainIds.contains(c.chainId) &&
            !existing.contains(c.chainId))
        .toList();
  }
}
