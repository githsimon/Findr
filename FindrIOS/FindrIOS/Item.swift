//
//  Item.swift
//  FindrIOS
//
//  Created by 杨颂 on 2025/3/14.
//

import Foundation
import SwiftData
import SwiftUI

// 物品分类枚举
enum ItemCategory: String, Codable, CaseIterable {
    case clothing = "衣物"
    case kitchen = "厨房"
    case books = "书籍"
    case tools = "工具"
    case electronics = "电子"
    case stationery = "文具"
    case decoration = "装饰"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .clothing:
            return "tshirt"
        case .kitchen:
            return "fork.knife"
        case .books:
            return "book"
        case .tools:
            return "hammer"
        case .electronics:
            return "gamecontroller"
        case .stationery:
            return "pencil"
        case .decoration:
            return "photo.artframe"
        case .other:
            return "square.grid.2x2"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing:
            return .red
        case .kitchen:
            return .blue
        case .books:
            return .green
        case .tools:
            return .purple
        case .electronics:
            return .yellow
        case .stationery:
            return .orange
        case .decoration:
            return .pink
        case .other:
            return .gray
        }
    }
}

// 物品标签
@Model
final class ItemTag {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

// 位置模型
@Model
final class Location {
    var name: String
    var icon: String
    var iconColor: String
    var sublocations: [String]
    @Relationship(deleteRule: .cascade, inverse: \Item.location)
    var items: [Item] = []
    
    init(name: String, icon: String, iconColor: String, sublocations: [String] = []) {
        self.name = name
        self.icon = icon
        self.iconColor = iconColor
        self.sublocations = sublocations
    }
}

// 物品模型
@Model
final class Item {
    var name: String
    var category: String
    var specificLocation: String
    var notes: String?
    var imageData: Data?
    var timestamp: Date
    var tags: [String] = []
    @Relationship(deleteRule: .nullify)
    var location: Location?
    var isFavorite: Bool = false
    
    init(name: String, category: String, location: Location? = nil, specificLocation: String, notes: String? = nil, imageData: Data? = nil, tags: [String] = [], timestamp: Date = Date()) {
        self.name = name
        self.category = category
        self.location = location
        self.specificLocation = specificLocation
        self.notes = notes
        self.imageData = imageData
        self.tags = tags
        self.timestamp = timestamp
    }
}
