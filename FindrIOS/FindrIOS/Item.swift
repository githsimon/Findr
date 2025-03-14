//
//  Item.swift
//  FindrIOS
//
//  Created by 杨颂 on 2025/3/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
