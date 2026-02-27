// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'ens_address_display.dart';

/// 简化的地址显示组件 - 用于列表等紧凑场景
class EnsAddressText extends StatelessWidget {
  final String address;
  final String coinType;
  final TextStyle? style;
  final int maxLines;
  final String? knownEnsName;

  const EnsAddressText({
    super.key,
    required this.address,
    this.coinType = 'ETH',
    this.style,
    this.maxLines = 1,
    this.knownEnsName,
  });

  @override
  Widget build(BuildContext context) {
    return EnsAddressDisplay(
      address: address,
      coinType: coinType,
      style: EnsDisplayStyle.compact,
      showAvatar: false,
      showCopy: false,
      textColor: style?.color,
      fontSize: style?.fontSize,
      maxLines: maxLines,
      knownEnsName: knownEnsName,
    );
  }
}
