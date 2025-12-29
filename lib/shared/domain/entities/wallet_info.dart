// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Shared Wallet Information Entity
///
/// This entity is shared across features that need basic wallet info
/// without creating direct feature dependencies.
class SharedWalletInfo {
  final String address;
  final String name;
  final int index;
  final String? chainType;
  final bool isSelected;

  const SharedWalletInfo({
    required this.address,
    required this.name,
    required this.index,
    this.chainType,
    this.isSelected = false,
  });

  SharedWalletInfo copyWith({
    String? address,
    String? name,
    int? index,
    String? chainType,
    bool? isSelected,
  }) {
    return SharedWalletInfo(
      address: address ?? this.address,
      name: name ?? this.name,
      index: index ?? this.index,
      chainType: chainType ?? this.chainType,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() {
    return 'SharedWalletInfo(address: $address, name: $name, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedWalletInfo &&
        other.address == address &&
        other.index == index;
  }

  @override
  int get hashCode => address.hashCode ^ index.hashCode;
}

