# Matrix 桥接部署指南 — 四平台（WhatsApp / Messenger / Instagram / Telegram）

> 目标 homeserver: `https://m.si46.world` (Synapse)
> 部署位置: IDC 服务器

---

## 架构总览

```
┌─────────────────────────────────────────────────────────┐
│                    IDC 服务器                             │
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  Synapse     │  │ PostgreSQL   │  │  Nginx       │   │
│  │  homeserver  │◄─┤  (5 个库)    │  │  (反代)      │   │
│  └──────┬───────┘  └──────────────┘  └──────────────┘   │
│         │ Application Service API                        │
│  ┌──────┴───────────────────────────────────────────┐   │
│  │              Docker Compose                       │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐   │   │
│  │  │ mautrix-   │ │ mautrix-   │ │ mautrix-   │   │   │
│  │  │ whatsapp   │ │ meta       │ │ meta       │   │   │
│  │  │ :29318     │ │ (messenger)│ │ (instagram)│   │   │
│  │  │            │ │ :29319     │ │ :29320     │   │   │
│  │  └────────────┘ └────────────┘ └────────────┘   │   │
│  │  ┌────────────┐                                   │   │
│  │  │ mautrix-   │                                   │   │
│  │  │ telegram   │                                   │   │
│  │  │ :29317     │                                   │   │
│  │  └────────────┘                                   │   │
│  └───────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

| 桥 | 镜像 | 端口 | Bot 用户名 | Ghost 前缀 | 命令前缀 |
|---|---|---|---|---|---|
| WhatsApp | `dock.mau.dev/mautrix/whatsapp:latest` | 29318 | `whatsappbot` | `whatsapp_` | (直接命令) |
| Messenger | `dock.mau.dev/mautrix/meta:latest` | 29319 | `messengerbot` | `messenger_` | `!fb` |
| Instagram | `dock.mau.dev/mautrix/meta:latest` | 29320 | `instagrambot` | `instagram_` | `!ig` |
| Telegram | `dock.mau.dev/mautrix/telegram:v0.15.3` | 29317 | `telegrambot` | `telegram_` | (直接命令) |

---

## 第 1 步：环境准备

### 1.1 系统要求

```bash
# 确认 Docker + Docker Compose
docker --version          # >= 20.10
docker compose version    # >= 2.0

# 确认 PostgreSQL
psql --version            # >= 14

# 确认网络连通
curl -I https://m.si46.world
curl -I https://web.whatsapp.com
curl -I https://www.messenger.com
curl -I https://www.instagram.com
curl -I https://api.telegram.org
```

### 1.2 创建目录

```bash
mkdir -p /opt/matrix-bridges/{whatsapp,messenger,instagram,telegram,backups,logs}
cd /opt/matrix-bridges
```

### 1.3 创建 PostgreSQL 数据库（4 个桥 + 已有 Synapse 库）

```bash
sudo -u postgres psql <<'SQL'
CREATE USER mautrix_whatsapp WITH PASSWORD '替换为强密码_WA';
CREATE DATABASE mautrix_whatsapp OWNER mautrix_whatsapp;

CREATE USER mautrix_messenger WITH PASSWORD '替换为强密码_FB';
CREATE DATABASE mautrix_messenger OWNER mautrix_messenger;

CREATE USER mautrix_instagram WITH PASSWORD '替换为强密码_IG';
CREATE DATABASE mautrix_instagram OWNER mautrix_instagram;

CREATE USER mautrix_telegram WITH PASSWORD '替换为强密码_TG';
CREATE DATABASE mautrix_telegram OWNER mautrix_telegram;
SQL
```

### 1.4 创建 Double Puppet 注册文件（四桥共用）

```bash
cat > /opt/matrix-bridges/doublepuppet-registration.yaml <<'EOF'
id: doublepuppet
url:
as_token: "$(openssl rand -hex 32)"
hs_token: "$(openssl rand -hex 32)"
sender_localpart: _doublepuppet
rate_limited: false
namespaces:
  users:
    - regex: '@.*:m\.si46\.world'
      exclusive: false
EOF

# 生成真正的随机 token
AS_TOKEN=$(openssl rand -hex 32)
HS_TOKEN=$(openssl rand -hex 32)
sed -i "s/\$(openssl rand -hex 32)/$AS_TOKEN/" /opt/matrix-bridges/doublepuppet-registration.yaml
sed -i "s/\$(openssl rand -hex 32)/$HS_TOKEN/" /opt/matrix-bridges/doublepuppet-registration.yaml

echo "Double Puppet AS Token: $AS_TOKEN"
echo "请记录此 token，四个桥的 config.yaml 都需要填入"
```

---

## 第 2 步：docker-compose.yml

```bash
cat > /opt/matrix-bridges/docker-compose.yml <<'EOF'
version: "3.8"

services:
  # ===== WhatsApp =====
  mautrix-whatsapp:
    image: dock.mau.dev/mautrix/whatsapp:latest
    container_name: mautrix-whatsapp
    restart: unless-stopped
    volumes:
      - ./whatsapp:/data
    ports:
      - "127.0.0.1:29318:29318"
    environment:
      - TZ=Asia/Shanghai

  # ===== Facebook Messenger =====
  mautrix-meta-messenger:
    image: dock.mau.dev/mautrix/meta:latest
    container_name: mautrix-meta-messenger
    restart: unless-stopped
    volumes:
      - ./messenger:/data
    ports:
      - "127.0.0.1:29319:29319"
    environment:
      - TZ=Asia/Shanghai

  # ===== Instagram DM =====
  mautrix-meta-instagram:
    image: dock.mau.dev/mautrix/meta:latest
    container_name: mautrix-meta-instagram
    restart: unless-stopped
    volumes:
      - ./instagram:/data
    ports:
      - "127.0.0.1:29320:29320"
    environment:
      - TZ=Asia/Shanghai

  # ===== Telegram =====
  mautrix-telegram:
    image: dock.mau.dev/mautrix/telegram:v0.15.3
    container_name: mautrix-telegram
    restart: unless-stopped
    volumes:
      - ./telegram:/data
    ports:
      - "127.0.0.1:29317:29317"
    environment:
      - TZ=Asia/Shanghai
EOF
```

---

## 第 3 步：生成默认配置

```bash
cd /opt/matrix-bridges

# 每个容器首次运行会生成默认 config.yaml
docker compose run --rm mautrix-whatsapp
docker compose run --rm mautrix-meta-messenger
docker compose run --rm mautrix-meta-instagram
docker compose run --rm mautrix-telegram
```

---

## 第 4 步：配置各桥

### 4.1 WhatsApp — `whatsapp/config.yaml`

```yaml
homeserver:
    address: https://m.si46.world
    domain: m.si46.world
    software: standard

appservice:
    address: http://localhost:29318
    hostname: 0.0.0.0
    port: 29318
    database:
        type: postgres
        uri: postgres://mautrix_whatsapp:替换为强密码_WA@localhost/mautrix_whatsapp?sslmode=disable
    id: whatsapp
    bot:
        username: whatsappbot
        displayname: WhatsApp Bridge Bot
        avatar: mxc://maunium.net/NeXNQarUbrlYBiPCpprYsRqr
    ephemeral_events: true
    async_transactions: true

bridge:
    username_template: whatsapp_{{.}}
    displayname_template: "{{.PushName}} (WA)"
    personal_filtering_spaces: true
    delivery_receipts: true
    message_status_events: true
    history_sync:
        backfill: true
        max_initial_conversations: 50
        request_full_sync: false
    whatsapp_thumbnail: true
    permissions:
        "*": relay
        "m.si46.world": user
        "@admin:m.si46.world": admin

encryption:
    allow: true
    default: true
    appservice: false
    allow_key_sharing: true
    verification_levels:
        receive: unverified
        send: unverified
        share: cross-signed-tofu

double_puppet:
    servers:
        m.si46.world: "<DOUBLEPUPPET_AS_TOKEN>"
    allow_discovery: false

logging:
    min_level: info
    writers:
        - type: stdout
          format: pretty-colored
        - type: file
          format: json
          filename: /data/logs/bridge.log
          max_size: 50
          max_backups: 7
          compress: true
```

**登录方式**: QR 码扫描（与 `@whatsappbot:m.si46.world` 私聊发送 `login`）

---

### 4.2 Messenger — `messenger/config.yaml`

```yaml
homeserver:
    address: https://m.si46.world
    domain: m.si46.world
    software: standard

appservice:
    address: http://localhost:29319
    hostname: 0.0.0.0
    port: 29319
    id: meta-messenger
    bot:
        username: messengerbot
        displayname: Messenger Bridge Bot
    username_template: messenger_{{.}}
    ephemeral_events: true

network:
    mode: messenger
    displayname_template: '{{or .DisplayName .Username "Unknown"}}'
    ig_e2ee: false
    min_full_reconnect_interval_seconds: 3600
    force_refresh_interval_seconds: 72000

database:
    type: postgres
    uri: postgres://mautrix_messenger:替换为强密码_FB@localhost/mautrix_messenger?sslmode=disable

bridge:
    command_prefix: "!fb"
    personal_filtering_spaces: true
    permissions:
        "*": relay
        "m.si46.world": user
        "@admin:m.si46.world": admin

encryption:
    allow: true
    default: true
    allow_key_sharing: true
    verification_levels:
        receive: unverified
        send: unverified
        share: cross-signed-tofu

double_puppet:
    secrets:
        m.si46.world: "as_token:<DOUBLEPUPPET_AS_TOKEN>"

logging:
    min_level: info
    writers:
        - type: stdout
          format: pretty-colored
        - type: file
          format: json
          filename: /data/logs/bridge.log
          max_size: 50
          max_backups: 7
          compress: true
```

**登录方式**: Cookie（浏览器 DevTools 复制 cURL）
1. 与 `@messengerbot:m.si46.world` 私聊发送 `login`
2. 隐私窗口打开 messenger.com，登录
3. DevTools → Network → 搜索 `graphql` → 右键 Copy as cURL
4. 将 cURL 命令粘贴给 Bot
5. **不要在浏览器中登出！直接关闭窗口**

---

### 4.3 Instagram — `instagram/config.yaml`

与 Messenger 相同，仅以下差异：

```yaml
appservice:
    address: http://localhost:29320
    hostname: 0.0.0.0
    port: 29320
    id: meta-instagram
    bot:
        username: instagrambot
        displayname: Instagram Bridge Bot
    username_template: instagram_{{.}}

network:
    mode: instagram
    ig_e2ee: false    # 设为 true 可启用 Instagram E2EE（走 WhatsApp 通道）

database:
    type: postgres
    uri: postgres://mautrix_instagram:替换为强密码_IG@localhost/mautrix_instagram?sslmode=disable

bridge:
    command_prefix: "!ig"
```

**登录方式**: 同 Messenger，但在 instagram.com 操作
- 所需 Cookie: `sessionid`, `csrftoken`, `mid`, `ig_did`, `ds_user_id`

---

### 4.4 Telegram — `telegram/config.yaml`

#### 前置：获取 API 凭据

1. 访问 https://my.telegram.org → 手机号登录
2. 点击 "API development tools" → 创建应用
3. 记录 `api_id`（数字）和 `api_hash`（32 位 hex）
4. **api_hash 无法撤销，妥善保管**

#### 前置：创建 Relay Bot

1. Telegram 中与 @BotFather 对话 → `/newbot` → 获取 Bot Token
2. `/setprivacy` → 选择你的 bot → **Disable**（否则无法读群消息）

#### 配置

```yaml
homeserver:
    address: https://m.si46.world
    domain: m.si46.world
    software: standard

appservice:
    address: http://localhost:29317
    hostname: 0.0.0.0
    port: 29317
    database: postgres://mautrix_telegram:替换为强密码_TG@localhost/mautrix_telegram?sslmode=disable
    database_opts:
        min_size: 1
        max_size: 10
    id: telegram
    bot_username: telegrambot
    bot_displayname: Telegram Bridge Bot
    bot_avatar: mxc://maunium.net/tJCRmUyJDsgRNgqhOGoiHWbX

bridge:
    username_template: "telegram_{userid}"
    alias_template: "telegram_{groupname}"
    displayname_template: "{displayname} (TG)"
    displayname_preference:
        - fullname
        - username
    max_initial_member_sync: 100
    sync_channel_members: true
    startup_sync: true
    backfill:
        enable: true
        normal_groups: 100
        megagroups: 100
        channels: 100
    permissions:
        "*": relaybot
        "m.si46.world": full
        "@admin:m.si46.world": admin
    relaybot:
        private_chat:
            state_changes: true
            message_formats:
                m.text: "<b>$sender_displayname</b>: $message"
                m.notice: "<b>$sender_displayname</b>: $message"
                m.emote: "* <b>$sender_displayname</b> $message"
                m.image: "<b>$sender_displayname</b> sent an image"
        ignore_unbridged_group_chat: true
        authless_portals: true
    animated_sticker:
        target: gif
        args:
            width: 256
            height: 256
            fps: 25
    encryption:
        allow: true
        default: true
        allow_key_sharing: true
        verification_levels:
            receive: unverified
            send: unverified
            share: cross-signed-tofu
    double_puppet:
        secrets:
            m.si46.world: "as_token:<DOUBLEPUPPET_AS_TOKEN>"

telegram:
    api_id: <你的 api_id>
    api_hash: "<你的 api_hash>"
    bot_token: "<relay_bot_token>"
    connection:
        timeout: 120
        retries: 5
        retry_delay: 1
        flood_sleep_threshold: 60
    catch_up: true
    sequential_updates: true

logging:
    version: 1
    formatters:
        normal:
            format: "[%(asctime)s] [%(levelname)s@%(name)s] %(message)s"
    handlers:
        console:
            class: logging.StreamHandler
            formatter: normal
        file:
            class: logging.handlers.RotatingFileHandler
            formatter: normal
            filename: /data/mautrix-telegram.log
            maxBytes: 10485760
            backupCount: 10
    loggers:
        mau:
            level: DEBUG
        telethon:
            level: INFO
    root:
        level: DEBUG
        handlers: [file, console]
```

**登录方式**: 手机号 + 验证码
1. 与 `@telegrambot:m.si46.world` 私聊发送 `login`
2. 发送手机号（含区号，如 `+8613800138000`）
3. 输入 Telegram 发来的验证码
4. 如有 2FA，输入密码

**Telegram 独有能力**:
- 群组/超级群组/频道完整桥接
- 消息编辑/删除双向同步
- 贴纸自动转 GIF
- 管理员权限映射（PL 50/75/95）
- Relay Bot 模式

---

## 第 5 步：生成 Registration 并注册到 Synapse

### 5.1 生成 registration 文件

```bash
cd /opt/matrix-bridges

# 启动后立即停止，会生成 registration.yaml
docker compose up -d
sleep 10
docker compose down
```

### 5.2 确认 registration 文件存在

```bash
ls -la whatsapp/registration.yaml
ls -la messenger/registration.yaml
ls -la instagram/registration.yaml
ls -la telegram/registration.yaml
```

### 5.3 注册到 Synapse

编辑 Synapse 的 `homeserver.yaml`：

```yaml
app_service_config_files:
  - /opt/matrix-bridges/doublepuppet-registration.yaml
  - /opt/matrix-bridges/whatsapp/registration.yaml
  - /opt/matrix-bridges/messenger/registration.yaml
  - /opt/matrix-bridges/instagram/registration.yaml
  - /opt/matrix-bridges/telegram/registration.yaml
```

> 路径需根据 Synapse 实际部署方式调整。Docker 部署需确保文件被挂载到容器内。

### 5.4 重启 Synapse

```bash
systemctl restart synapse
# 或
docker restart synapse
```

### 5.5 启动所有桥

```bash
cd /opt/matrix-bridges
docker compose up -d
docker compose logs -f   # 确认四个桥都显示 "Bridge started" 或类似成功日志
```

---

## 第 6 步：生产加固

### 6.1 健康检查脚本

```bash
cat > /opt/matrix-bridges/health-check.sh <<'SCRIPT'
#!/bin/bash
# 每 5 分钟执行一次 (crontab: */5 * * * *)
LOG="/opt/matrix-bridges/logs/health.log"

declare -A BRIDGES=(
  ["whatsapp"]="29318"
  ["messenger"]="29319"
  ["instagram"]="29320"
  ["telegram"]="29317"
)

for NAME in "${!BRIDGES[@]}"; do
  PORT=${BRIDGES[$NAME]}
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:$PORT/_matrix/mau/bridge/v1/status" 2>/dev/null || echo "000")

  if [ "$CODE" != "200" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $NAME (port $PORT) unhealthy: HTTP $CODE" >> "$LOG"

    # 仅重启出问题的容器
    CONTAINER="mautrix-$NAME"
    [ "$NAME" = "messenger" ] && CONTAINER="mautrix-meta-messenger"
    [ "$NAME" = "instagram" ] && CONTAINER="mautrix-meta-instagram"

    docker restart "$CONTAINER" >> "$LOG" 2>&1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restarted $CONTAINER" >> "$LOG"
  fi
done
SCRIPT
chmod +x /opt/matrix-bridges/health-check.sh
```

添加 crontab：
```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/matrix-bridges/health-check.sh") | crontab -
```

### 6.2 自动备份脚本

```bash
cat > /opt/matrix-bridges/backup.sh <<'SCRIPT'
#!/bin/bash
# 每天 03:00 执行 (crontab: 0 3 * * *)
DIR="/opt/matrix-bridges/backups/$(date +%Y%m%d)"
mkdir -p "$DIR"

# 备份数据库
for DB in mautrix_whatsapp mautrix_messenger mautrix_instagram mautrix_telegram; do
  pg_dump -U "$DB" "$DB" 2>/dev/null | gzip > "$DIR/$DB.sql.gz"
done

# 备份配置文件
for BRIDGE in whatsapp messenger instagram telegram; do
  cp "/opt/matrix-bridges/$BRIDGE/config.yaml" "$DIR/${BRIDGE}-config.yaml" 2>/dev/null
  cp "/opt/matrix-bridges/$BRIDGE/registration.yaml" "$DIR/${BRIDGE}-registration.yaml" 2>/dev/null
done

# 备份 double puppet
cp /opt/matrix-bridges/doublepuppet-registration.yaml "$DIR/" 2>/dev/null

# 清理 30 天前的备份
find /opt/matrix-bridges/backups -maxdepth 1 -mtime +30 -exec rm -rf {} +

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed: $DIR" >> /opt/matrix-bridges/logs/backup.log
SCRIPT
chmod +x /opt/matrix-bridges/backup.sh
```

添加 crontab：
```bash
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/matrix-bridges/backup.sh") | crontab -
```

### 6.3 日志轮转

Docker 自身日志配置（可加入 docker-compose.yml 每个 service）：

```yaml
logging:
  driver: json-file
  options:
    max-size: "50m"
    max-file: "5"
```

---

## 第 7 步：常用运维命令

```bash
cd /opt/matrix-bridges

# 查看所有容器状态
docker compose ps

# 查看某个桥的日志
docker compose logs -f mautrix-whatsapp
docker compose logs -f mautrix-meta-messenger
docker compose logs -f mautrix-meta-instagram
docker compose logs -f mautrix-telegram

# 重启单个桥
docker compose restart mautrix-whatsapp

# 更新镜像
docker compose pull
docker compose up -d

# 停止所有桥
docker compose down
```

---

## 第 8 步：验证清单

### 基础验证
- [ ] `docker compose ps` 四个容器全部 running
- [ ] 各容器日志无 appservice 注册错误
- [ ] Synapse 日志无 appservice 相关报错

### Bot 可达性
- [ ] 搜索到 `@whatsappbot:m.si46.world`
- [ ] 搜索到 `@messengerbot:m.si46.world`
- [ ] 搜索到 `@instagrambot:m.si46.world`
- [ ] 搜索到 `@telegrambot:m.si46.world`

### WhatsApp
- [ ] 发送 `login` 收到 QR 码
- [ ] 手机扫码成功
- [ ] 消息双向桥接正常
- [ ] 图片/语音/文件传输正常

### Messenger
- [ ] 发送 `login` 获得 Cookie 登录指引
- [ ] 粘贴 cURL 后登录成功
- [ ] 消息双向桥接正常

### Instagram
- [ ] 同 Messenger 流程
- [ ] 图片/Story 回复正常

### Telegram
- [ ] 发送 `login` → 手机号 → 验证码流程完成
- [ ] 群组/频道自动同步
- [ ] 贴纸转 GIF 显示正常
- [ ] 消息编辑/删除同步

### Double Puppeting
- [ ] 从外部平台发消息，Matrix 侧显示为自己的真实账号（非 ghost）

### 生产加固
- [ ] 健康检查脚本正常执行
- [ ] 备份脚本正常执行
- [ ] 容器重启后自动重连

---

## 已知限制与注意事项

| 平台 | 限制 |
|---|---|
| **WhatsApp** | 每号最多关联 4 台设备（桥算 1 台）；大量群发有封号风险 |
| **Messenger** | Cookie 会过期（几周~几月），需重新登录；Meta 可能标记可疑活动锁定账户 |
| **Instagram** | 加密 DM 默认显示占位符；XMA 媒体（Reels/Stories）默认不回填 |
| **Telegram** | Python 实现，正在 megabridge 重写中；FloodWait 限流可能暂停同步 |
| **通用** | E2BE 偶有密钥共享问题；桥重启期间消息可能丢失；Cookie/Session 不要在浏览器中登出 |
