//
//  N42Attributes.swift
//  Runner
//
//  Created by jyw on 2024/11/25.
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
var activity: Activity<N42Attributes>?
struct N42Attributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
            // Dynamic stateful properties about your activity go here!
            var value: Int
        }

        // Fixed non-changing properties about your activity go here!
        var name: String
}
