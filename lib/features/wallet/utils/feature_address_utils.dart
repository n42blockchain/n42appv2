// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Shared lightweight address guards for feature entry pages.
class FeatureAddressUtils {
  static final RegExp _evmAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  static String normalize(String? address) => address?.trim() ?? '';

  static bool hasValue(String? address) => normalize(address).isNotEmpty;

  static bool isValidEvmAddress(String? address) {
    return _evmAddressRegExp.hasMatch(normalize(address));
  }
}
