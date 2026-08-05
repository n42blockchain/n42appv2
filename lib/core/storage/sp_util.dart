// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> normalizeMarketWatchlistSymbols(Iterable<dynamic> symbols) {
  final normalized = <String>[];
  final seen = <String>{};
  for (final symbol in symbols) {
    final value = symbol.toString().trim().toLowerCase();
    if (value.isEmpty || !seen.add(value)) continue;
    normalized.add(value);
  }
  return normalized;
}

/// Shared Preferences Utility
///
/// Provides a centralized interface for local storage operations.
/// Handles user preferences, settings, and cached data.
/// Sensitive data (wallet, security, user info) uses SecureStorage.
/// Non-sensitive data uses SharedPreferences.
class SPUtil {
  SharedPreferences? prefs;
  final SecurePreferences _securePrefs = SecurePreferences.instance;

  Future<SharedPreferences> initPrefs() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
      await _securePrefs.init();
    }
    return prefs!;
  }

  /// 解析存储的 JSON 字符串为字符串列表，失败时返回空列表
  List<String> _decodeJsonList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (json.decode(raw) as List<dynamic>).cast<String>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SPUtil._decodeJsonList] JSON decode failed: $e');
      }
      return [];
    }
  }

  /// 解析存储的 JSON 字符串为 Map，失败时返回 null
  Map<String, dynamic>? _decodeJsonMap(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SPUtil._decodeJsonMap] JSON decode failed: $e');
      }
      return null;
    }
  }

  // ==================== 非敏感设置 ====================

  // 是否阅读了登录、安全条款
  Future<void> setReadLoginClause(bool value) async {
    await initPrefs();
    prefs?.setBool(SPkey.readLoginClause.name, value);
  }

  Future<bool> getReadLoginClause() async {
    await initPrefs();
    return prefs?.getBool(SPkey.readLoginClause.name) ?? false;
  }

  // app主题模式0系统，1亮，2暗
  Future<void> setThemeMode(int value) async {
    await initPrefs();
    prefs?.setInt(SPkey.themeMode.name, value);
  }

  Future<int?> getThemeMode() async {
    await initPrefs();
    return prefs?.getInt(SPkey.themeMode.name);
  }

  // 自定义主色调 — 存 ARGB int；0 或 null 表示使用默认色
  Future<void> setAccentColor(int value) async {
    await initPrefs();
    prefs?.setInt(SPkey.accentColor.name, value);
  }

  Future<int?> getAccentColor() async {
    await initPrefs();
    return prefs?.getInt(SPkey.accentColor.name);
  }

  // app系统语言,en,zh-CN
  Future<void> setSysLang(String value) async {
    await initPrefs();
    prefs?.setString(SPkey.sysLang.name, value);
  }

  Future<String?> getSysLang() async {
    await initPrefs();
    return prefs?.getString(SPkey.sysLang.name);
  }

  // 浏览器设置browserSetting
  Future<void> setBrowserSetting(Map<String, dynamic> value) async {
    await initPrefs();
    prefs?.setString(SPkey.browserSetting.name, json.encode(value));
  }

  Future<Map<String, dynamic>?> getBrowserSetting() async {
    await initPrefs();
    return _decodeJsonMap(prefs?.getString(SPkey.browserSetting.name));
  }

  // ==================== 敏感数据（使用 SecurePreferences） ====================

  // 保存钱包信息（安全存储）
  Future<void> setWalletInfo(Map<String, dynamic> map) async {
    await _securePrefs.setWalletInfo(map);
  }

  /// 获取钱包列表（安全存储）
  Future<Map<String, dynamic>?> getWalletInfo() {
    return _securePrefs.getWalletInfo();
  }

  // 钱包安全验证配置（安全存储）
  Future<void> setSecurity(Map<String, dynamic> value) async {
    await _securePrefs.setSecurity(value);
  }

  Future<Map<String, dynamic>?> getSecurity() {
    return _securePrefs.getSecurity();
  }

  // 保存用户信息（安全存储）
  Future<void> saveUserInfo(UserInfo? info) async {
    await _securePrefs.setUserInfo(info?.toJson());
  }

  // 保存用户信息 (JSON format for SharedUserInfo)（安全存储）
  Future<void> saveUserInfoJson(Map<String, dynamic> info) async {
    await _securePrefs.setUserInfo(info);
  }

  // 获取缓存的用户信息（安全存储）
  Future<Map<String, dynamic>?> getUserInfo() {
    return _securePrefs.getUserInfo();
  }

  // 挖矿数据（安全存储）
  // uuid 与 WalletActionProvider.defaultWalletUUID / wallet_providers 的兜底保持一致：
  // 未登录（默认钱包）时用 'AstranetWallet'，否则挖矿数据存不进/读不出（数据丢失）。
  String get _miningUuid => AppGlobals.userInfo?.uuid?.isNotEmpty == true
      ? AppGlobals.userInfo!.uuid!
      : 'AstranetWallet';

  Future<void> setMiningData(Map<String, dynamic> value) async {
    await _securePrefs.setMiningData(_miningUuid, value);
  }

  Future<Map<String, dynamic>?> getMiningData() async {
    return await _securePrefs.getMiningData(_miningUuid);
  }

  // ==================== 非敏感设置（继续使用 SharedPreferences） ====================

  // 设置后台挖矿音乐
  Future<void> setBackgroundMiningMusic(int value) async {
    await initPrefs();
    prefs?.setInt(SPkey.backgroundMiningMusic.name, value);
  }

  // 获取后台挖矿音乐
  Future<int?> getBackgroundMiningMusic() async {
    await initPrefs();
    return prefs?.getInt(SPkey.backgroundMiningMusic.name);
  }

  Future<bool> hasAcceptedTerms() async {
    await initPrefs();
    return prefs?.getBool(SPkey.hasAcceptedChatTerms.name) ?? false;
  }

  Future<void> setHasAcceptedTerms(bool value) async {
    await initPrefs();
    prefs?.setBool(SPkey.hasAcceptedChatTerms.name, value);
  }

  // 服务条款
  Future<void> setShowTermsOfService(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.showTermsOfService.name, value);
  }

  Future<bool> getShowTermsOfService() async {
    await initPrefs();
    return prefs?.getBool(SPkey.showTermsOfService.name) ?? false;
  }

  // 推送权限提醒：用户是否已选择"不再提醒"
  Future<bool> getPushPermissionDismissed() async {
    await initPrefs();
    return prefs?.getBool(SPkey.pushPermissionDismissed.name) ?? false;
  }

  Future<void> setPushPermissionDismissed(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.pushPermissionDismissed.name, value);
  }

  Future<DateTime?> getPushPermissionLastPromptAt() async {
    await initPrefs();
    final value = prefs?.getInt(SPkey.pushPermissionLastPromptAt.name);
    if (value == null || value <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setPushPermissionLastPromptAt(DateTime value) async {
    await initPrefs();
    await prefs?.setInt(
      SPkey.pushPermissionLastPromptAt.name,
      value.millisecondsSinceEpoch,
    );
  }

  // 后台送达引导（自启动+电池白名单）：用户是否已选择"不再提醒"
  Future<bool> getBgDeliveryGuideDismissed() async {
    await initPrefs();
    return prefs?.getBool(SPkey.bgDeliveryGuideDismissed.name) ?? false;
  }

  Future<void> setBgDeliveryGuideDismissed(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.bgDeliveryGuideDismissed.name, value);
  }

  Future<DateTime?> getBgDeliveryGuideLastPromptAt() async {
    await initPrefs();
    final value = prefs?.getInt(SPkey.bgDeliveryGuideLastPromptAt.name);
    if (value == null || value <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setBgDeliveryGuideLastPromptAt(DateTime value) async {
    await initPrefs();
    await prefs?.setInt(
      SPkey.bgDeliveryGuideLastPromptAt.name,
      value.millisecondsSinceEpoch,
    );
  }

  // 小额资产隐藏开关（< $1 USD 的代币不在资产列表中显示）
  Future<void> setHideSmallAssets(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.hideSmallAssets.name, value);
  }

  Future<bool> getHideSmallAssets() async {
    await initPrefs();
    return prefs?.getBool(SPkey.hideSmallAssets.name) ?? false;
  }

  // 小额资产过滤阈值（0 = 关闭过滤；>0 = 过滤掉 value < threshold 的代币）
  // 支持的档位：0, 1, 5, 10, 50
  Future<void> setSmallAssetsThreshold(double threshold) async {
    await initPrefs();
    await prefs?.setDouble(SPkey.smallAssetsThreshold.name, threshold);
  }

  Future<double> getSmallAssetsThreshold() async {
    await initPrefs();
    final stored = prefs?.getDouble(SPkey.smallAssetsThreshold.name);
    if (stored != null) return stored;
    // 向后兼容：旧版用 bool hideSmallAssets，若为 true 则迁移为 $1 阈值
    final oldBool = prefs?.getBool(SPkey.hideSmallAssets.name) ?? false;
    return oldBool ? 1.0 : 0.0;
  }

  // 行情自选列表（存储 coin symbol lowercase）
  Future<List<String>> getMarketWatchlist() async {
    await initPrefs();
    return normalizeMarketWatchlistSymbols(
      _decodeJsonList(prefs?.getString(SPkey.marketWatchlist.name)),
    );
  }

  Future<void> saveMarketWatchlist(List<String> list) async {
    await initPrefs();
    await prefs?.setString(
      SPkey.marketWatchlist.name,
      json.encode(normalizeMarketWatchlistSymbols(list)),
    );
  }

  // 资产搜索历史（最近 10 条关键词，按时间倒序）
  Future<List<String>> getCoinSearchHistory() async {
    await initPrefs();
    return _decodeJsonList(prefs?.getString(SPkey.coinSearchHistory.name));
  }

  Future<void> saveCoinSearchHistory(List<String> history) async {
    await initPrefs();
    await prefs?.setString(SPkey.coinSearchHistory.name, json.encode(history));
  }

  // ==================== V1 挖矿专用方法 ====================

  /// 获取 V1 挖矿状态（按地址存储）
  /// 格式：{ address: { miningType: String, miningValue: {...} } }
  Future<Map<String, dynamic>?> getMiningStautus() async {
    await initPrefs();
    return _decodeJsonMap(prefs?.getString(SPkey.miningV1Status.name));
  }

  /// 设置某地址的 V1 挖矿状态
  Future<void> setMiningStatus(String address, Map<String, dynamic> map) async {
    await initPrefs();
    final existing = await getMiningStautus() ?? {};
    existing[address] = {...(existing[address] as Map? ?? {}), ...map};
    await prefs?.setString(SPkey.miningV1Status.name, json.encode(existing));
  }

  /// 更新某地址挖矿状态中的某个子字段
  // ignore: non_constant_identifier_names
  Future<void> setMiningStatus_child(
    String address,
    String key,
    dynamic value,
  ) async {
    await initPrefs();
    final existing = await getMiningStautus() ?? {};
    final addrData = Map<String, dynamic>.from(existing[address] as Map? ?? {});
    final miningValue = Map<String, dynamic>.from(
      addrData['miningValue'] as Map? ?? {},
    );
    miningValue[key] = value;
    addrData['miningValue'] = miningValue;
    existing[address] = addrData;
    await prefs?.setString(SPkey.miningV1Status.name, json.encode(existing));
  }

  /// 获取当前选中的 V1 挖矿节点
  Future<Map<String, dynamic>?> getCurrNodeAddress() async {
    await initPrefs();
    return _decodeJsonMap(prefs?.getString(SPkey.miningV1NodeAddress.name));
  }

  /// 设置当前选中的 V1 挖矿节点
  Future<void> setCurrNodeAddress(Map<dynamic, dynamic> node) async {
    await initPrefs();
    await prefs?.setString(SPkey.miningV1NodeAddress.name, json.encode(node));
  }

  /// 获取 V1 挖矿是否开启
  Future<bool> getOpenMining() async {
    await initPrefs();
    return prefs?.getBool(SPkey.miningV1OpenMining.name) ?? true;
  }

  /// 设置 V1 挖矿开关
  Future<void> setMiningOpen(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.miningV1OpenMining.name, value);
  }

  /// 获取是否使用主链挖矿
  Future<bool?> getIsMainChainMining() async {
    await initPrefs();
    return prefs?.getBool(SPkey.mainChainMining.name);
  }

  /// 设置是否使用主链挖矿
  Future<void> setIsMainChainMining(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.mainChainMining.name, value);
  }

  /// 读取挖矿 UI 版本选择：true = V2（默认），false = V1
  Future<bool> getMiningUseV2() async {
    await initPrefs();
    return prefs?.getBool(SPkey.miningUiVersion.name) ?? true;
  }

  /// 保存挖矿 UI 版本选择
  Future<void> setMiningUseV2(bool useV2) async {
    await initPrefs();
    await prefs?.setBool(SPkey.miningUiVersion.name, useV2);
  }

  // ==================== 通用方法 ====================

  /// 保存bool值
  Future<bool?> setBoolValue(String key, bool value) async {
    await initPrefs();
    return await prefs?.setBool(key, value);
  }

  /// 获取 bool值
  /// 首次取不到 返回false
  Future<bool> getBoolValue(String key, {bool? defaultValue = false}) async {
    await initPrefs();
    return prefs?.getBool(key) ?? defaultValue ?? false;
  }

  // ── Token auto-discovery: ignored contracts ──────────────────────────────

  /// Returns the set of contract addresses the user has dismissed in the
  /// token discovery flow.
  Future<Set<String>> getIgnoredTokenContracts() async {
    await initPrefs();
    return _decodeJsonList(
      prefs?.getString(SPkey.ignoredTokenContracts.name),
    ).map((c) => c.trim()).where((c) => c.isNotEmpty).toSet();
  }

  /// Persists [contracts] to the ignored list (merges with existing).
  Future<void> addIgnoredTokenContracts(Iterable<String> contracts) async {
    await initPrefs();
    final existing = await getIgnoredTokenContracts();
    existing.addAll(contracts.map((c) => c.trim()).where((c) => c.isNotEmpty));
    await prefs?.setString(
      SPkey.ignoredTokenContracts.name,
      json.encode(existing.toList()),
    );
  }

  /// Convenience method to ignore a single contract address.
  Future<void> addIgnoredTokenContract(String contract) =>
      addIgnoredTokenContracts([contract]);
}

/// Storage Keys
enum SPkey {
  themeMode, // app主题模式0系统，1亮，2暗
  sysLang, // 系统语言en,zh-CN
  browserSetting, // 浏览器设置
  walletInfo, // 钱包信息（已迁移到 SecureStorage）
  security, // 安全设置（已迁移到 SecureStorage）
  userInfo, // 用户信息（已迁移到 SecureStorage）
  backgroundMiningMusic, // 后台挖矿音乐
  hasAcceptedChatTerms, // 是否阅读Chat 用户须知
  showTermsOfService, // 显示服务条款
  miningData, // 挖矿数据（已迁移到 SecureStorage）
  readLoginClause, // 是否阅读登录条款
  hideSmallAssets, // 小额资产隐藏（< $1 USD）
  coinSearchHistory, // 资产搜索历史记录（最近 10 条关键词）
  recentSendAddresses, // 最近转账地址 JSON：Map<coinType, List<{address,name?,time}>>
  gasAlertSettings, // Gas 价格提醒配置 JSON：Map<symbol, GasAlertConfig>
  ensExpiryReminders, // ENS 域名到期提醒配置 JSON：Map<domainName, EnsExpiryReminderConfig>
  miningV1Status, // V1 挖矿状态（按地址）
  miningV1NodeAddress, // V1 当前选中节点
  miningV1OpenMining, // V1 挖矿开关
  mainChainMining, // 是否使用主链挖矿
  miningUiVersion, // 挖矿 UI 版本：true = V2（默认），false = V1
  marketWatchlist, // 行情自选列表，JSON List<String> 存 coin symbol（lowercase）
  coinPriceAlerts, // 币价到价提醒配置，JSON Map<coinId, CoinPriceAlertConfig>
  accentColor, // 自定义主色调，存 ARGB int（0 表示默认蓝色）
  ignoredTokenContracts, // 代币自动发现：用户手动忽略的合约地址 JSON List<String>
  smallAssetsThreshold, // 小额资产过滤阈值（double: 0=关闭, 1/5/10/50 表示过滤低于该 USD 价值的代币）
  pushPermissionDismissed, // 用户已明确关闭推送权限提醒，不再弹窗
  pushPermissionLastPromptAt, // 推送权限提醒最近展示时间，避免短时间反复弹窗
  bgDeliveryGuideDismissed, // 用户已明确关闭后台送达引导（自启动+电池白名单）
  bgDeliveryGuideLastPromptAt, // 后台送达引导最近展示时间，避免短时间反复跳设置
}
