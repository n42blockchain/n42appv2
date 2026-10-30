# 商店描述修订稿

待发布渠道使用；未写入 App Store Connect。不能将本轮 2.5.3 源码测试映射成商店 1.0.18 验收。

N42 Wallet helps you manage assets and connect to decentralized applications. Available networks and features vary by app version and platform. Check the current network list and transaction details in the app.

Before signing, review the network, asset, amount, recipient, contract permissions and network fee. Keep your recovery phrase private. Account recovery and key export depend on the account type and signing provider.

Cryptographic research does not certify the security of every wallet component. SHA-384 is a hash function and does not provide post-quantum transaction signatures.

发布前须将 Passkey、硬件钱包、AA/批量交易、swap/limit order、资产及语言数量分别关联到 `feature-evidence.json` 中实际商店构建证据。证据为空的能力不能当作本次发布承诺。
