part of 'wallet_action_provider.dart';

/// Wallet CRUD operations: create, import, delete, save, find, backup, key management.
extension WalletActionProviderWallet on WalletActionProvider {
  /// 从 JSON 列表解析钱包，填充 _walletInfoLsit 并设置 index。
  void _loadWalletList(Map<String, dynamic> source) {
    walletIndex = source['index'];
    walletMiningIndex = source['miningIndex'] ?? walletIndex;
    if (walletMiningIndex == -1) walletMiningIndex = walletIndex;
    _walletInfoLsit = (source['wallet'] as List<dynamic>? ?? [])
        .map((e) => WalletInfo.fromJson(e))
        .toList();
  }

  //读取钱包信息
  Future<void> getWalletInfo() async {
    Map<String, dynamic>? walletAll = await SPUtil().getWalletInfo();
    if (walletAll == null) {
      await createWallet();
    } else {
      final walletUser = walletAll[userUUID];
      if (walletUser != null) {
        _loadWalletList(walletUser);
        await _restoreMnemonics();
      } else {
        final walletDefault = walletAll["AstranetWallet"];
        if (walletDefault != null) {
          _loadWalletList(walletDefault);
          await _restoreMnemonics();
          walletAll[userUUID] = walletDefault;
          walletAll.remove("AstranetWallet");
          await SPUtil().setWalletInfo(walletAll);
        } else {
          await createWallet();
        }
      }
    }
    _load = Load.finish;
    refresh();
  }

  /// 从 SecureStorage 恢复被 WalletDataMigration 清除的 mnemonic
  Future<void> _restoreMnemonics() async {
    final secureStorage = SecureStorage();
    for (int i = 0; i < _walletInfoLsit.length; i++) {
      final wallet = _walletInfoLsit[i];
      if (wallet.hasMnemonic) continue;
      final walletId = wallet.timestamp ?? '${userUUID}_$i';
      final mnemonic = await secureStorage.getMnemonic(walletId);
      if (mnemonic != null && mnemonic.isNotEmpty) {
        wallet.mnemonic = mnemonic;
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Restored mnemonic for wallet $walletId',
          );
        }
      }
    }
  }

  Future<void> initWallet({bool shouldInitCoinInfo = false}) async {
    if (buildwallet == true) return;
    buildwallet = true;
    try {
      await getWalletInfo();
      await _mergeCustomChains();
      await _syncNewChains();
      await buildCoinModel();
    } finally {
      buildwallet = false;
      refresh();
    }
    if (shouldInitCoinInfo) {
      eventBus.fire(
        EventPublic(
          EventPublicType.selectWallet,
          intValue: walletIndex,
          stringValue: "wallet",
        ),
      );
      initCoinInfo();
    }
    await refreshWalletListNotifier();
  }

  /// 把用户添加的自定义 EVM 链合并进链注册表。
  ///
  /// 自定义链此前只存独立的 SharedPreferences（`custom_evm_chains`），与真正
  /// 驱动余额/转账的 `chainUrlMap`/`allChainUrlMap` 不通。这里在建 coinModel
  /// 前把它们注入两张表——之后 [_syncNewChains] 会像对待内建新链一样自动把
  /// 它们加进每个钱包的 coinInfo，`SenderFactory` 也能按 coinType 查到
  /// blockchainType=Ethereum 分派给 EvmSender。EVM 的派生/签名/查询/广播在
  /// Dart 与 native 两端都链无关（未知 coinType 兜底 Ethereum 曲线，chainId
  /// 走 txData），发送时经 baseInfo.custom 标志走自定义 RPC（见 EvmSender）。
  Future<void> _mergeCustomChains() async {
    try {
      final customChains = await CustomChainService.getCustomChains();
      for (final chain in customChains) {
        final key = CustomChainService.coinTypeKey(chain.chainId);
        // 不覆盖内建链（key 以 C<chainId> 前缀，本就不会与枚举名冲突）。
        if (chainUrlMap.containsKey(key)) continue;
        final entry = CustomChainService.toRegistryEntry(chain);
        chainUrlMap[key] = entry;
        allChainUrlMap[key] = entry;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WalletActionProvider: _mergeCustomChains error: $e');
      }
    }
  }

  /// 同步新链到现有钱包
  /// 检查 chainUrlMap 中是否有新链不在当前钱包中，如果有则自动添加。
  /// 同时修复存储数据中错误的 service/service_test URL（如历史 bug 写入的 N42 RPC）。
  Future<void> _syncNewChains() async {
    if (_walletInfoLsit.isEmpty) return;

    bool hasChanges = false;

    // 遍历所有钱包
    for (int walletIdx = 0; walletIdx < _walletInfoLsit.length; walletIdx++) {
      final wallet = _walletInfoLsit[walletIdx];

      if (normalizeWatchOnlyWallet(wallet, supportedChains: chainUrlMap)) {
        hasChanges = true;
      }
      if (wallet.watchOnly) {
        continue;
      }
      if (wallet.coinInfo == null) continue;

      // 检查 chainUrlMap 中的每条链
      for (final chainKey in chainUrlMap.keys) {
        final chainConfig = chainUrlMap[chainKey];
        if (chainConfig == null) continue;

        if (!wallet.coinInfo!.containsKey(chainKey)) {
          // 新链：添加到钱包
          if (chainConfig['showList'] == true) {
            wallet.coinInfo![chainKey] = _deepCopyChainConfig(chainConfig);
            hasChanges = true;
            if (kDebugMode) {
              debugPrint(
                'WalletActionProvider: Added new chain $chainKey to wallet ${wallet.walletName}',
              );
            }
          }
        } else {
          // 已有链：同步 service/service_test URL（修复历史 bug 写入的错误 RPC）
          final canonicalBase = chainConfig['baseInfo'];
          if (canonicalBase is! Map) continue;
          final storedChain = wallet.coinInfo![chainKey];
          if (storedChain is! Map) continue;
          final storedBase = storedChain['baseInfo'];
          if (storedBase is! Map) continue;

          bool changed = false;
          // 早期版本曾把已保存的 S 链 baseInfo 按 ETH 回退，导致 Sonic 资产
          // 显示为 ETH，并把余额、转账和交易记录请求发到以太坊。链 key 已明确
          // 是 S，因此以规范 Sonic 元数据修复身份字段；余额缓存保留，稍后会按
          // Sonic RPC 刷新。
          if (chainKey == CoinType.S.name &&
              (storedBase['coinType'] != CoinType.S.name ||
                  storedBase['name'] != canonicalBase['name'])) {
            const sonicIdentityKeys = <String>{
              'blockchainType',
              'coinType',
              'icon',
              'name',
              'miniName',
              'unit',
              'decimals',
              'mKey',
              'path',
              'chainId',
              'chainId_test',
              'contract',
              'contract_test',
              'canEdit',
              'rules',
            };
            for (final key in sonicIdentityKeys) {
              if (canonicalBase.containsKey(key) &&
                  storedBase[key] != canonicalBase[key]) {
                storedBase[key] = _deepCopyValue(canonicalBase[key]);
                changed = true;
              }
            }
            for (final key in const <String>[
              'mainnetChainID',
              'testnetChainID',
            ]) {
              if (chainConfig.containsKey(key) &&
                  storedChain[key] != chainConfig[key]) {
                storedChain[key] = chainConfig[key];
                changed = true;
              }
            }
          }
          final canonicalService = canonicalBase['service'];
          final canonicalServiceTest = canonicalBase['service_test'];
          if (canonicalService != null &&
              storedBase['service'] != canonicalService) {
            storedBase['service'] = canonicalService;
            changed = true;
          }
          if (canonicalServiceTest != null &&
              storedBase['service_test'] != canonicalServiceTest) {
            storedBase['service_test'] = canonicalServiceTest;
            changed = true;
          }

          // 链注册表新增的官方代币也要同步到已有钱包。过去只新增整条链，
          // 导致已创建钱包永远看不到后来接入的官方 ERC-20（如 N42 上的
          // S Coin），而新创建的钱包却正常，造成版本间资产展示不一致。
          final canonicalTokens = chainConfig['mainnets'];
          final storedTokens = storedChain['mainnets'];
          if (canonicalTokens is Map && storedTokens is Map) {
            for (final entry in canonicalTokens.entries) {
              final canonicalToken = entry.value;
              final canonicalContract = canonicalToken is Map
                  ? canonicalToken['contract']?.toString().toLowerCase()
                  : null;
              final alreadyAdded =
                  storedTokens.containsKey(entry.key) ||
                  (canonicalContract != null &&
                      storedTokens.values.any((token) {
                        return token is Map &&
                            token['contract']?.toString().toLowerCase() ==
                                canonicalContract;
                      }));
              if (!alreadyAdded) {
                storedTokens[entry.key] = _deepCopyValue(entry.value);
                changed = true;
              }
            }
          }
          if (changed) hasChanges = true;
        }
      }
    }

    // 如果有变更，保存钱包信息
    if (hasChanges) {
      for (int i = 0; i < _walletInfoLsit.length; i++) {
        await saveWalletInfo(_walletInfoLsit[i], i);
      }
      if (kDebugMode) {
        debugPrint(
          'WalletActionProvider: Synced chains and service URLs to all wallets',
        );
      }
    }
  }

  dynamic _deepCopyValue(dynamic value) {
    if (value is Map) return _deepCopyMap(value);
    if (value is List) return _deepCopyList(value);
    return value;
  }

  //创建钱包
  Future<void> createWallet() async {
    WalletInfo wInfo = WalletInfo(
      walletName: "",
      password: "",
      walletUuid: userUUID,
    );
    wInfo.mnemonic = await Trustdart().generateMnemonic();
    wInfo.walletName = "Account${walletInfoLsit.length + 1}";
    wInfo.coinInfo = chainUrlMap;
    wInfo.mainWallet = true;
    wInfo.timestamp = "${DateTime.now().millisecondsSinceEpoch}";
    await addWalletInfo(wInfo);
  }

  ///添加钱包
  Future<void> addWalletInfo(WalletInfo info) async {
    try {
      // 克隆一份数据，不污染数据源（存储时不保存助记词）
      final newWalletInfo = WalletInfo.fromJson(info.toJson());
      _walletInfoLsit.add(info);
      walletIndex = _walletInfoLsit.length - 1;
      if (walletMiningIndex == -1) {
        walletMiningIndex = walletIndex;
      }
      await saveWalletInfo(newWalletInfo, walletIndex, isNewWallet: true);
      // 同步将 mnemonic/privateKey 写入 SecureStorage，防止迁移清除 JSON 后丢失
      if (info.hasMnemonic) {
        final walletId = info.timestamp ?? '${userUUID}_$walletIndex';
        await SecureStorage().saveMnemonic(
          walletId: walletId,
          mnemonic: info.mnemonic!,
        );
      }
      initWallet(shouldInitCoinInfo: true);
      refresh();
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }

  /// 添加观察钱包（Watch-only）
  /// [name] 钱包显示名称；[address] 要追踪的 EVM 地址（0x...）
  Future<void> addWatchOnlyWallet(String name, String address) async {
    final wInfo = WalletInfo(
      walletName: name.trim().isEmpty
          ? 'Watch ${_walletInfoLsit.length + 1}'
          : name.trim(),
      password: '0', // 非空，避免触发备份提示
      walletUuid: userUUID,
    );
    wInfo.watchOnly = true;
    wInfo.watchAddress = address.trim();
    wInfo.mnemonic = '';
    wInfo.privateKey = '';
    wInfo.coinInfo = buildWatchOnlyCoinInfo(chainUrlMap);
    wInfo.mainWallet = false;
    wInfo.timestamp = '${DateTime.now().millisecondsSinceEpoch}';
    await addWalletInfo(wInfo);
  }

  ///删除一个钱包
  Future<MessageModel?> deleteWalletInfo({WalletInfo? info}) async {
    if (_walletInfoLsit.isEmpty) return null;
    if (info == null) {
      //不传 默认移除第一个
      _walletInfoLsit.removeAt(0);
      // Clamp walletIndex after removal
      if (walletIndex >= _walletInfoLsit.length) {
        walletIndex = _walletInfoLsit.length - 1;
      }
      return null;
    } else {
      final rIndex = _walletInfoLsit.indexWhere((e) => e == info);
      if (rIndex == -1) return null;

      final wallet = _walletInfoLsit[rIndex];
      final miningChainConfig = walletDeletionMiningChainConfig(wallet);
      if (miningChainConfig != null) {
        final pathMap = Map<String, dynamic>.from(
          miningChainConfig['baseInfo']['path'] as Map,
        );
        final addrType = miningChainConfig['addrType'].toString();
        var rmAddress = await Trustdart().generateAddress(
          CoinType.N.name,
          getPathWithIndex(pathMap[addrType], miningChainConfig['pathIndex']),
          addrType,
          mnemonic: wallet.mnemonic ?? "",
          pk: wallet.privateKey ?? "",
        );
        String miningAddress = rmAddress[addrType];
        var miningData = globalMiningInstance.miningData?[miningAddress];
        if (miningData != null && miningData['isMining'] == true) {
          MessageModel rmm = MessageModel.error();
          rmm.data =
              "The validator's wallet cannot be deleted!"; //"验证者钱包，无法删除！";
          return rmm;
        }
      }
      if (rIndex < walletIndex) {
        walletIndex--;
        _walletInfoLsit.remove(info);
        //setWalletIndex(walletIndex);
      } else {
        _walletInfoLsit.remove(info);
      }
      saveWalletInfoAll();
      return null;
    }
  }

  //isFirst 用户第一次创建钱包 缓存中还未有数据
  Future<int> checkWalletMnemonic(WalletInfo info) async {
    try {
      final valid = await Trustdart().checkMnemonic(info.mnemonic!);
      return valid ? 0 : -1;
    } catch (e) {
      return -1;
    }
  }

  WalletInfo? findWallet({String pk = "", String mnemonic = ""}) {
    final index = walletInfoLsit.indexWhere(
      (e) => pk.isNotEmpty ? e.privateKey == pk : e.mnemonic == mnemonic,
    );
    return index == -1 ? null : walletInfoLsit[index];
  }

  //返回公钥、私钥对
  Future<void> getPublicKeyAndPrivateKeyPairN() async {
    _publicKeyAndPrivateKeyPair = {};
    Trustdart trustdart = Trustdart();
    for (WalletInfo wInfo in walletInfoLsit) {
      if (wInfo.mainWallet == false) {
        continue;
      }
      // 检查 coinInfo 和 N 链配置是否存在
      if (wInfo.coinInfo == null || wInfo.coinInfo![CoinType.N.name] == null) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Skipping wallet ${wInfo.walletName} - coinInfo or N chain config is null',
          );
        }
        continue;
      }
      final nChainConfig = wInfo.coinInfo![CoinType.N.name];
      if (nChainConfig['baseInfo'] == null ||
          nChainConfig['baseInfo']['path'] == null) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Skipping wallet ${wInfo.walletName} - N chain baseInfo or path is null',
          );
        }
        continue;
      }
      // EDGE-M03: 验证路径配置完整性，防止 addrType 不存在时产生难以追踪的空指针
      final pathMap = nChainConfig['baseInfo']?['path'];
      final addrType = nChainConfig['addrType'] as String?;
      if (pathMap == null || addrType == null || pathMap[addrType] == null) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Invalid path config for ${wInfo.walletName}, addrType=$addrType',
          );
        }
        continue;
      }
      try {
        String path = getPathWithIndex(
          pathMap[addrType],
          nChainConfig['pathIndex'],
        );
        String privateKeyStr = await trustdart.getPrivateKeyAndPublicKeyPair(
          CoinType.N.name,
          path,
          mnemonic: wInfo.mnemonic ?? "",
          pk: wInfo.privateKey ?? "",
        );
        if (privateKeyStr.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              'WalletActionProvider: Empty key pair response for ${wInfo.walletName}',
            );
          }
          continue;
        }
        Map<dynamic, dynamic> pkPair = json.decode(privateKeyStr);
        final pubKey = bytesToHex(base64Decode(pkPair['publicKey'].toString()));
        final privateKey = bytesToHex(
          base64Decode(pkPair['privateKey'].toString()),
        );
        _publicKeyAndPrivateKeyPair![pubKey] = privateKey;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Failed to load key pair for ${wInfo.walletName}: $e',
          );
        }
      }
    }
  }

  String? getPrivateKeyWithPublicKey(String publicKey) {
    return _publicKeyAndPrivateKeyPair?[publicKey];
  }

  //设置主钱包
  MessageModel setMainWallet(int wIndex) {
    final index = walletInfoLsit.indexWhere((e) => e.mainWallet == true);
    if (index == -1) {
      final rmm = MessageModel.error();
      rmm.data = "Main wallet not found!";
      return rmm;
    }
    walletInfoLsit[index].mainWallet = false;
    walletInfoLsit[wIndex].mainWallet = true;
    saveWalletInfoAll();
    eventBus.fire(
      EventPublic(
        EventPublicType.selectWallet,
        intValue: -1,
        stringValue: "mainwallet",
      ),
    );
    return MessageModel();
  }

  //保存钱包修改到SPUtil
  //isNewWallet，是否是添加新钱包
  Future<void> saveWalletInfo(
    WalletInfo newWalletInfo,
    int wIndex, {
    bool isNewWallet = false,
  }) async {
    try {
      final sPUtils = SPUtil();
      Map<String, dynamic>? walletAll = await sPUtils.getWalletInfo();
      if (walletAll == null) {
        await sPUtils.setWalletInfo({
          userUUID: {
            "index": 0,
            "miningIndex": 0,
            "wallet": [newWalletInfo.toJson()],
          },
        });
      } else {
        final userWallets = walletAll[userUUID];
        if (userWallets == null) {
          walletAll[userUUID] = {
            "index": 0,
            "miningIndex": 0,
            "wallet": [newWalletInfo.toJson()],
          };
        } else {
          if (isNewWallet) {
            (userWallets['wallet'] as List).add(newWalletInfo.toJson());
          } else {
            userWallets['wallet'][wIndex] = newWalletInfo.toJson();
          }
          userWallets['index'] = wIndex;
          userWallets['miningIndex'] = walletMiningIndex;
          walletAll[userUUID] = userWallets;
        }
        await sPUtils.setWalletInfo(walletAll);
      }
      await refreshWalletListNotifier();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("saveWalletInfo error: $e");
      }
    }
  }

  //保存钱包数据
  Future<void> saveWalletInfoAll() async {
    SPUtil sPUtils = SPUtil();
    Map<String, dynamic>? walletAll = await sPUtils.getWalletInfo();
    if (walletAll != null) {
      walletAll[userUUID]['wallet'] = walletInfoLsit
          .map((e) => e.toJson())
          .toList();
      walletAll[userUUID]['index'] = walletIndex;
      walletAll[userUUID]['miningIndex'] = walletMiningIndex;
      await sPUtils.setWalletInfo(walletAll);
      await refreshWalletListNotifier();
    }
  }

  //刷新缓存
  Future<void> refreshWalletListNotifier() async {
    // 刷新 WalletListNotifier 以同步数据
    try {
      final walletService = globalProviderContainer.read(walletServiceProvider);
      if (walletService != null) {
        await walletService.refreshWallets();
        if (kDebugMode) {
          debugPrint(
            "saveWalletInfo: WalletListNotifier refreshed successfully",
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            "saveWalletInfo: WalletService not available, skipping refresh",
          );
        }
      }
    } catch (refreshError) {
      if (kDebugMode) {
        debugPrint(
          "saveWalletInfo: Error refreshing WalletListNotifier: $refreshError",
        );
      }
      // 不抛出异常，因为保存已经成功
    }
  }

  //添加一个导入钱包
  Future<bool> addImportWalletInfo(WalletInfo info) async {
    try {
      if (info.walletName == null || info.walletName!.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Cannot add import wallet - walletName is null or empty',
          );
        }
        return false;
      }
      final walletNameUpper = info.walletName!.toUpperCase();
      final chainMapWallet = walletMap[walletNameUpper];
      if (chainMapWallet == null) {
        if (kDebugMode) {
          debugPrint(
            'WalletActionProvider: Cannot add import wallet - chain config not found for $walletNameUpper',
          );
        }
        return false;
      }
      final chainMap = Map<String, dynamic>.from(chainMapWallet);
      chainMap['baseInfo']['isTest'] = false;
      chainMap['baseInfo']['mainnets'] = {};
      chainMap['baseInfo']['balance'] = "0";
      chainMap['baseInfo']['balance_test'] = "0";
      chainMap['baseInfo']['canEdit'] = false;
      info.coinInfo = {walletNameUpper: chainMap};
      await saveWalletInfo(info, walletInfoLsit.length, isNewWallet: true);
      initWallet();
      return true;
    } catch (e) {
      return false;
    }
  }
}
