//
//  N42ChatCallAttributes.swift
//  Runner / N42 (shared — must be a member of BOTH targets)
//
//  聊天通话进行中活动（Live Activity）的 ActivityAttributes。
//  与挖矿用的 N42Attributes 完全独立，避免互相干扰。
//
//  ⚠️ Target membership：本文件需同时勾选 Runner 与 N42（widget extension）
//  两个 target，否则 AppDelegate 的处理器或 widget 任一侧编译不过。
//

import Foundation
import ActivityKit

/// 当前聊天通话活动（与挖矿的 `activity` 全局变量独立）
@available(iOS 16.1, *)
var chatCallActivity: Activity<N42ChatCallAttributes>?

@available(iOS 16.1, *)
struct N42ChatCallAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// 动态副标题（如通话状态/时长文本），可经 updateLiveActivity 更新
        var body: String
    }

    /// 固定标题（如「通话中」），活动期间不变
    var title: String
}
