# iOS WalletCorePlugin.swift 全链签名重构核对(草案)

来源:dev513 分支上对 `ios/Runner/WalletCorePlugin.swift` 的整体重写(master 自分叉点
`7b40478e` 起从未改过此文件,故 cherry-pick 不存在合并冲突;风险在于"合上后对不对",
不在"能不能合上")。本文档记录逐 case 行为核对结果,作为落地前的真机回归依据。

## API 面核对

master 与 dev513 的 24 个顶层 `case` 方法名逐一对比,**完全一致,无新增/删除**:
generateMnemonic / checkMnemonic / generateAddress / validateAddress /
signTransaction / signTransaction_btc_p2wsh / signTransaction_byteArray /
signMessage / getPublicKey / getPrivateKey / getKeyStore /
getWalletInfoWithKeyStore / getTransactionMaxValue / getPrivateKeyAndPublicKey /
LiveActivityStart / LiveActivityUpdate / LiveActivityEnd / Permissions /
getPubKeySOL / MiningGenerateBls12381Keypair / MiningCreateDepositUnsignedTx /
MiningCreateExitUnsignedTx / MiningCreateGetExitFeeUnsignedTx / MiningRunClient

## 已深入核对、确认为真实改进的两处

### 1. 私钥路径的强制解包崩溃风险(高优先级)

master 里 **13 处**都是这个写法:

```swift
let d: Data = Base64.decode(string: pkStr!)!
let pk: PrivateKey = PrivateKey.init(data: d)!
```

分布在 generateAddress / 5 个 sign* 方法 / getPublicKey / getPrivateKey /
getKeyStore / getWalletInfoWithKeyStore / getTransactionMaxValue /
getPrivateKeyAndPublicKey —— 只要调用方传入格式不对的私钥字符串(base64 解码失败,
或解码出的字节数不能构成合法私钥),就是 `!` 强制解包 `nil`,直接 fatal error 崩溃整个
App,而不是返回 Flutter 错误。

dev513 统一改成:

```swift
guard let d = Base64.decode(string: pkStr), let pk = PrivateKey(data: d) else {
    return .failure(FlutterError(code: "invalid_pk", message: "...", details: nil))
}
```

其中 5 个 sign* 方法(signTransaction / signTransaction_btc_p2wsh /
signTransaction_byteArray / signMessage / getTransactionMaxValue)共用新抽出的
`resolveKey(from:)` helper,行为经逐行核对与原有的
"mnemonic 非空走助记词 / 否则 pk 非空走私钥 / 否则报 no_wallet" 分支逻辑等价,
仅去掉了 13 处崩溃点。

**结论**:这不是纯格式重构,是一个跨 13 个调用点的真实崩溃修复,而且这些方法都在
资金签名路径上——是本次重构最有价值、也最需要真机验证"传错私钥格式不再崩溃、传对
私钥依然签得出正确结果"的部分。

### 2. `MiningRunClient` 重复回调(中优先级,已在 master 侧确认是 bug)

master 现状(`ios/Runner/WalletCorePlugin.swift` 当前 `MiningRunClient` case):

```swift
let flutterResult = result
MobileSdk.runClient(wsUrl: wsUrl, validatorPrivateKey: validatorPrivateKey, completion: { mobileResult in
    switch mobileResult {
    case .success: flutterResult("Client started")
    case .failure(let err): flutterResult(FlutterError(code: "ClientError", message: "\(err)", details: nil))
    }
})
flutterResult("Client started")   // <- 派发异步调用后立即又调用一次
break
```

`result`/`flutterResult` 被调用了两次(一次同步、一次在异步 completion 里),Flutter
engine 对同一个 `FlutterResult` 重复调用通常会触发 "Results already submitted" 断言。
dev513 版本去掉了那行多余的同步调用,只在 completion 里调用一次。

**结论**:真实 bug,修复方式正确,可以直接采纳。

## 尚待逐条核对的 case(建议真机回归覆盖)

以下 case 在 dev513 中同样经历了 force-unwrap → guard-let 的机械改写,尚未逐行核对
是否有除崩溃修复外的行为差异,建议按下表顺序做真机回归:

| Case | 涉及链路 | 备注 |
|---|---|---|
| generateAddress | 全链地址生成 | 已知触发私钥崩溃修复(见上) |
| getPublicKey / getPrivateKey / getPrivateKeyAndPublicKey | 全链密钥导出 | 已知触发私钥崩溃修复 |
| getKeyStore / getWalletInfoWithKeyStore | Keystore 导入导出 | 待逐行核对 |
| getPubKeySOL | Solana | 待逐行核对 |
| LiveActivityStart/Update/End | 灵动岛/来电 UI | 与签名无关,风险低 |
| Permissions | 相机/相册权限 | 与签名无关,风险低 |
| MiningGenerateBls12381Keypair / MiningCreateDepositUnsignedTx / MiningCreateExitUnsignedTx / MiningCreateGetExitFeeUnsignedTx | 挖矿质押 | 待逐行核对 |

## 真机回归建议清单(合并前必须过)

- [ ] EVM 转账签名(mnemonic 路径 + 私钥导入路径)
- [ ] BTC 签名(p2wsh)
- [ ] TON 签名(本次问题的起因)
- [ ] Solana 签名(getPubKeySOL)
- [ ] AA 生产签名路径(ECDSA via `trustdart.signMessage`,见 `aa_transfer_handler`)
- [ ] 故意传入格式错误的私钥字符串,确认新版本返回 Flutter 错误而非崩溃(回归验证上面发现的 13 处崩溃点)
- [ ] 挖矿启动(MiningRunClient),确认不再出现重复 result 断言
- [ ] LiveActivity 开始/更新/结束

## 结论

这份 dev513 重写值得合并,且不只是"统一代码风格"——它修掉了签名路径上 13 处真实的
强制解包崩溃点和 1 处挖矿启动的重复回调 bug。但改动面覆盖了几乎所有原生签名方法,
必须先完成上面的真机回归清单,再并入 master,不建议直接合并。
