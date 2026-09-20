# P13a — 本地操作收据查询

日期：2026-09-20。状态：实现与窄测试完成，待主代理审查提交。

## 独立功能及协议

仅修改 `backend/payment-sandbox/server.py`、`test_server.py`、README 与本文；没有修改核心账本、Flutter 或提交。

`GET /operations/{id}`：与既有接口相同的 synthetic Bearer 鉴权。支持 `transfer_`、`packet_`、`refund_` 加 64 位小写十六进制 ID。不接收 query 或 body，不允许 sender 覆盖。

SQL 同时限定 ID、当前鉴权 actor 与支持的 kind，成功返回原始存储 receipt，保持 `mode=localSimulation` 与十进制整数字符串。其他账号（包括转账收款方）、不存在及不支持的 seed/claim ID 均返回同样的 404 JSON。不输出资金细节或是否存在的区别。

这是已知 ID 的本地模拟收据读取，没有写入资金、没有链上/支付机构确认状态。红包创建收据表示原创建操作，不是当前剩余或领取明细。超时未拿到 ID 仍使用原 key + 同参重试；直接按幂等键查询留到下一独立步骤。

## 测试证据

```sh
python3 -m unittest discover -s backend/payment-sandbox -p test_server.py -v
```

共 **10 tests passed**（原 7 + 新增 3），日志 `/tmp/n42-payment-order-query-tests.log`。

新增覆盖：三类操作查询与原收据完全相同且不改变守恒结果；跨账号/收款方与不存在统一 404；seed/claim/格式非法 ID；无 token；禁止 sender query 与 GET body；HTTP 服务重启后收据仍可查且原键重试不重复扣款。

## 提交建议与边界

建议英文标题：`feat: query actor-scoped local payment receipts`。

保留仅 loopback、仅 localSimulation 及无真实资金边界。重启持久性针对同一 SQLite 文件；临时启动器退出删除账本后自然无法查询旧操作。Flutter client 接入由主代理独立完成。
