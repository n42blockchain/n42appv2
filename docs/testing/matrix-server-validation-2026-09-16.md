# Matrix 服务端注册及 Android 恢复验证

## 结果

- 用户确认 SSH 用户为 `ubuntu`；登录和免交互 sudo 验证成功。
- 线上 homeserver 为 Tuwunel 1.8.2，应用使用 `https://m.si46.world`。
- 普通用户名密码注册已恢复，并通过真实账号注册／登录验证。
- 当前连接 Android 已重新安装并启动完整应用开发检查版 `2.4.8（2026072672）`。本轮未上传新 TestFlight，也未发布正式 APK。原先自动卸载导致的本机数据清除未被恢复。
- 通话另外发现 TURN 网关错误，尚未修复；不能据此宣布双手机音视频已通过。

## 注册修复

生效配置来自部署目录 `source/deployment/11x/matrix/tuwunel.toml`，以只读 bind mount 挂载至容器 `/etc/tuwunel.toml`。环境变量没有覆盖注册开关。修改前 `allow_registration = false`，公开注册接口返回 HTTP 403 / M_FORBIDDEN / Registration has been disabled。

备份存放在服务器当前管理员用户的 `.local/state/n42-maintenance/matrix-registration-20260917T032409Z/tuwunel.toml.before`，文件权限 0600，备份目录权限 0700；配置和凭证没有复制到本仓库。仅修改下面两个开关：

```toml
[global]
allow_registration = true
yes_i_am_very_very_sure_i_want_an_open_registration_server_prone_to_abuse = true
```

这启用普通公开用户名密码注册，无额外注册邀请码。保留现有管理员共享密钥、TURN 密钥、数据库和其他配置。按挂载文件原 inode 写入，再对 homeserver 发送 SIGUSR1 热加载；容器 PID 和启动时间未变化，健康状态保持 healthy。配置语义及信号依据 [Tuwunel v1.8.2 配置](https://raw.githubusercontent.com/matrix-construct/tuwunel/v1.8.2/tuwunel-example.toml) 和 [配置热加载说明](https://matrix-construct.github.io/tuwunel/deploying/configuration-reload.html)。

回滚方式：在服务器恢复上述私有备份至原配置文件，保持挂载 inode，再发送 SIGUSR1；复查公开注册接口及容器健康。不要把含密钥的完整配置加入 Git。

## 实际服务端验证

| 检查 | 结果 |
| --- | --- |
| 空注册请求 | 403 改为 401，返回正常的 m.login.dummy 验证流程 |
| 用户名可用性查询 | HTTP 200，available=true |
| 临时账号 A、B 分别注册 | 两次均 HTTP 200 |
| 密码登录与注销额外测试会话 | 通过 |
| A 创建加密私聊并邀请 B | B 的 /sync 返回邀请，自己的成员事件带 is_direct=true，邀请人为 A |
| B 接受邀请 | 双方成员状态均 join；双方 m.direct 映射可读；B 同步包含加入房间 |
| B 反向邀请 A，A 拒绝 | 邀请可达；拒绝后状态 leave，接收方同步不再列出该邀请 |
| 已登录用户获取 TURN 配置 | HTTP 200，有 URI 和临时凭证；不等于媒体可用 |

注册／登录／邀请／TURN 凭证共 7 项程序检查通过。两个账号由测试临时创建；结束后退出房间、移除本地房间关联并停用账号。没有使用 dxx／dxx01 的登录信息或修改其资料。临时密码与 token 不进入日志或仓库，失败清理用的 0600 临时凭证文件已删除。

这些验证证明当前服务端可以收发与接受／拒绝标准 Matrix 私聊邀请，不证明旧安装包的联系人界面已修复，也没有进行用户历史消息恢复或真正的双手机音视频测试。

## TURN 故障：待前置网关授权

当前服务端仅下发 `turns:turn.si46.world:443?transport=tcp`。证书校验和 TLS 连接成功，但发送标准 TURN Allocate 请求后收到 `HTTP/1.1 400 Bad Request`，并非 TURN 响应。部署中的同名 Nginx 配置也使用 HTTP location/proxy_pass；TURN 需要对应的传输层代理，不能用该 HTTP 转发方式替代。协议参考 [RFC 8656](https://www.rfc-editor.org/rfc/rfc8656.html)。

后端 coturn 在本机 3478 UDP 响应标准 401 challenge，共享密钥与 homeserver 一致。主机 UFW 未启用，iptables INPUT/OUTPUT 为 ACCEPT；从当前电脑直连后端 3478 UDP/TCP 超时，前端 3478/5349 TCP 被拒绝。外部连通性仍需结合网关及上游网络检查，不能仅凭这些结果认定云防火墙是唯一原因。

TURN 的 external-ip 指向前置网关而非后端网卡；是否存在配套的中继端口映射尚未确认，因此没有盲目改写该地址，也没有把不可达地址下发给客户端。使用 ubuntu 和现有密钥登录前置网关被拒绝，已向用户请求该网关的正确 SSH 用户／端口及公钥授权。

下一步：检查网关实际监听、TLS/传输层转发和 UDP 中继端口映射，修复后验证带认证的 TURN 分配、双向媒体中继，再用反馈的 Android／iPhone 两账号验证通话。
