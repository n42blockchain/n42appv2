// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// 后台消息送达引导：判断是否为对后台进程 / FCM data-only 推送有激进限制
// 的国产 ROM。这类设备需引导用户手动开启「自启动」+ 加入「电池优化白
// 名单」，否则后台/杀进程状态收不到消息。
//
// 真机实测（Redmi / HyperOS，2026-06-14）：app 不在 `dumpsys deviceidle
// whitelist` 中 → 系统后台/杀进程不唤醒本 app 收 FCM（同机 WhatsApp 在
// 白名单故正常）。pusher 注册侧 OK，纯属厂商后台限制。详见
// docs/PUSH_NOTIFICATIONS.md。
library;

const Set<String> _aggressiveBackgroundVendors = {
  'xiaomi', 'redmi', 'poco',
  'oppo', 'oneplus', 'realme',
  'vivo', 'iqoo',
  'huawei', 'honor',
  'meizu',
};

/// [brand] 来自 `AndroidDeviceInfo.brand`（已小写）。命中则该 ROM 对后台
/// 推送有激进限制，应引导用户开自启动 + 电池白名单。Pixel / 三星国际版 /
/// 其它原生接近的 ROM 返回 false（FCM 后台正常，无需打扰用户）。
bool isAggressiveBackgroundRom(String brand) =>
    _aggressiveBackgroundVendors.contains(brand.trim().toLowerCase());
