//
//  N42ChatCallLiveActivity.swift
//  N42 (widget extension target)
//
//  聊天通话进行中活动的锁屏 / 灵动岛 UI。读取 N42ChatCallAttributes 的
//  固定标题与动态 body，独立于挖矿活动（N42LiveActivity）。
//
//  ⚠️ Target membership：本文件需属于 N42（widget extension）target；
//  依赖的 N42ChatCallAttributes 需同属 N42 与 Runner。
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct N42ChatCallLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: N42ChatCallAttributes.self) { context in
            // 锁屏 / 横幅 UI
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.title)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                    if !context.state.body.isEmpty {
                        Text(context.state.body)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 13))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if !context.state.body.isEmpty {
                        Text(context.state.body)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 13))
                    }
                }
            } compactLeading: {
                Image(systemName: "phone.fill").foregroundColor(.green)
            } compactTrailing: {
                Text(context.attributes.title)
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                    .lineLimit(1)
            } minimal: {
                Image(systemName: "phone.fill").foregroundColor(.green)
            }
            .widgetURL(URL(string: "n42app://chat"))
            .keylineTint(Color.green)
        }
    }
}
