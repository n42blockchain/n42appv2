# N42 Wallet 代码审计 TODO

## 审计进度

**起始问题数**: 2611
**当前问题数**: 435
**已修复**: 2176 (83%)
**最后更新**: 2026-01-24

---

## 已完成任务

### Phase 1: 自动化扫描与基础修复 ✅
- [x] 运行 `dart analyze` 静态分析
- [x] 更新 `analysis_options.yaml` 排除生成文件
- [x] 禁用 `constant_identifier_names` 规则（加密货币符号约定）

### Phase 2: 类型安全修复 ✅
- [x] 修复所有 `strict_top_level_inference` 警告
- [x] 添加返回类型注解到 200+ 方法
- [x] 修复 `MessageModel?` → `MessageModel` 赋值问题 (40+ 处)
- [x] 修复 `String?` → `String` 类型转换
- [x] 修复 `TransationRecordModel?` 空值处理

### Phase 3: 命名规范修复 ✅
- [x] `UserUUID` → `userUUID`
- [x] `WalletName` → `walletName`
- [x] 其他 snake_case → camelCase 转换

### Phase 4: 返回值修复 ✅
- [x] `transfer_api.dart`: 修复 `return;` → `return rmm;`
- [x] `redeem.dart`: 修复 `signP2WSH` 和 `redeem` 返回类型
- [x] `self_custody1.dart`: 修复 `createP2WSH` 和 `getUTXO2`
- [x] `app_database.dart`: 添加缺失的 `return null;`
- [x] `browser_api.dart`: 修正返回类型

### Phase 5: 函数签名修复 ✅
- [x] `buttonStyle2`: `VoidCallback` → `VoidCallback?`
- [x] `buttonStyle3`: `VoidCallback` → `VoidCallback?`

### Phase 6: 小问题修复 ✅
- [x] 移除不必要的 `await`（void 方法）
- [x] 添加 `context.mounted` 检查
- [x] 修复 `sort_child_properties_last`
- [x] 字符串插值替代拼接

---

## 待完成任务

### 🔴 P0 - AppGlobals 重构 (435 个警告)

所有剩余警告都是 `deprecated_member_use_from_same_package`，与 `AppGlobals` 相关。

**涉及文件** (主要):
- `lib/src/wallet/provider/wallet_action_provider.dart`
- `lib/src/wallet/api/transfer_api.dart`
- `lib/src/browser/provider/browser_provider.dart`
- `lib/src/chat/provider/`
- `lib/src/widgets/app_bar_widget.dart`
- `lib/src/widgets/prompt_widget.dart`
- 等 50+ 文件

**重构方案**:
1. 创建新分支 `refactor/remove-app-globals`
2. 使用 Provider 或 GetIt 替代全局状态
3. 逐模块迁移：
   - [ ] `AppGlobals.appContext` → 通过 widget tree 传递 context
   - [ ] `AppGlobals.userInfo` → 使用 Provider/UserProvider
   - [ ] `AppGlobals.currentId` → 使用单独的 ID 生成器服务

**执行命令**:
```bash
# 查看所有 AppGlobals 使用位置
grep -rn "AppGlobals" lib/src/ | grep -v "deprecated" | head -50
```

### 🟠 P1 - 安全审计 (待执行)

根据审计计划，以下安全检查待完成：

#### 1. 加密实现审计
- [ ] 审查 `/lib/src/chat/utils/aes_utils.dart` - 硬编码 IV 问题
- [ ] 审查 `/lib/features/chat/data/services/chat_crypto_service_impl.dart`
- [ ] 实现 PBKDF2 密钥派生

#### 2. 密钥管理审计
- [ ] 审查 `/lib/core/security/secure_storage.dart`
- [ ] 实现敏感数据内存擦除机制
- [ ] 评估私钥加密层

#### 3. 存储安全审计
- [ ] 评估 SQLite 加密方案 (sqlcipher)
- [ ] SharedPreferences 敏感信息迁移

#### 4. 网络安全审计
- [ ] SSL Pinning 完善
- [ ] 证书指纹配置

### 🟡 P2 - 代码质量 (待执行)

- [ ] 异常处理完善
- [ ] 资源释放检查
- [ ] 并发安全检查

### 🟢 P3 - 性能审计 (待执行)

- [ ] 启动性能分析
- [ ] 内存使用优化
- [ ] 列表滚动性能

---

## 快速恢复命令

```bash
# 检查当前问题数
dart analyze lib/ 2>&1 | tail -3

# 查看非 deprecated 错误
dart analyze lib/ 2>&1 | grep -v "deprecated_member_use_from_same_package" | grep -E "error|warning"

# 统计 AppGlobals 使用数量
grep -rn "AppGlobals" lib/src/ | wc -l
```

---

## 相关文件

- 审计计划: `/Users/jieliu/.claude/plans/sharded-chasing-octopus.md`
- 分析配置: `/Users/jieliu/Documents/n42/n42appv2/analysis_options.yaml`

---

## 备注

- 所有修改已应用，无需提交
- AppGlobals 重构是架构改动，建议单独分支进行
- 安全审计需要更深入的代码审查
