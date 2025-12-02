//
//  N42LiveActivity.swift
//  N42
//
//  Created by jyw on 2024/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct N42LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: N42Attributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                Text("Verifying")
                    .foregroundColor(Color.white)
                    .font(.system(size: 30))
                //\(context.state.value)"
                Image("mining").resizable().aspectRatio(contentMode: .fit).frame(width: 40)
            }
            .activityBackgroundTint(Color.blue)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Verifying").foregroundColor(Color.white)
                        .font(.system(size:20))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image("mining").resizable().aspectRatio(contentMode: .fit).frame(width: 30)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("N42Wallet").foregroundColor(Color.white)
                        .font(.system(size:20))
                }
            } compactLeading: {
                Text("Verifying").foregroundColor(Color.white)
                    .font(.system(size:20))
            } compactTrailing: {
                Image("mining").resizable().scaledToFit()
            } minimal: {
                Image("mining").resizable().scaledToFit()
            }
            .widgetURL(URL(string: "n42app://n42.ai"))
            .keylineTint(Color.red)
        }
    }
}
