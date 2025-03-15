//
//  Item.swift
//  FindrIOS
//
//  Created by 杨颂 on 2025/3/14.
//

import Foundation
import SwiftData
import SwiftUI
import CoreData

// 注册安全转换器
extension NSSecureUnarchiveFromDataTransformer {
    static let transformerName = NSValueTransformerName(rawValue: "NSSecureUnarchiveFromDataTransformer")
    
    static func register() {
        let transformer = NSSecureUnarchiveFromDataTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: transformerName)
    }
}

// 在应用启动时注册转换器
class TransformerRegistration {
    static func register() {
        NSSecureUnarchiveFromDataTransformer.register()
    }
}

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

// 子位置模型
@Model
final class Sublocation {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Location.sublocations)
    var location: Location?
    
    init(name: String) {
        self.name = name
    }
}

// 标签模型
@Model
final class Tag {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Item.tags)
    var item: Item?
    
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
    @Relationship(deleteRule: .cascade)
    var sublocations: [Sublocation] = []
    @Relationship(deleteRule: .cascade, inverse: \Item.location)
    var items: [Item] = []
    
    init(name: String, icon: String, iconColor: String, sublocationNames: [String] = []) {
        self.name = name
        self.icon = icon
        self.iconColor = iconColor
        // 初始化时创建子位置对象
        self.sublocations = sublocationNames.map { Sublocation(name: $0) }
        self.sublocations.forEach { $0.location = self }
    }
    
    // 获取子位置名称数组
    var sublocationNames: [String] {
        return sublocations.map { $0.name }
    }
    
    // 添加子位置
    func addSublocation(_ name: String) {
        let sublocation = Sublocation(name: name)
        sublocation.location = self
        sublocations.append(sublocation)
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
    @Relationship(deleteRule: .cascade)
    var tags: [Tag] = []
    @Relationship(deleteRule: .nullify)
    var location: Location?
    var isFavorite: Bool = false
    
    init(name: String, category: String, location: Location? = nil, specificLocation: String, notes: String? = nil, imageData: Data? = nil, tagNames: [String] = [], timestamp: Date = Date()) {
        self.name = name
        self.category = category
        self.location = location
        self.specificLocation = specificLocation
        self.notes = notes
        self.imageData = imageData
        self.timestamp = timestamp
        // 初始化时创建标签对象
        self.tags = tagNames.map { Tag(name: $0) }
        self.tags.forEach { $0.item = self }
    }
    
    // 获取标签名称数组
    var tagNames: [String] {
        return tags.map { $0.name }
    }
    
    // 添加标签
    func addTag(_ name: String) {
        let tag = Tag(name: name)
        tag.item = self
        tags.append(tag)
    }
}
