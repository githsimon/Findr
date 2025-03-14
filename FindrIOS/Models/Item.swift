import Foundation
import SwiftUI

struct Item: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var category: Category
    var locationID: UUID
    var sublocationName: String?
    var specificLocation: String?
    var notes: String?
    var tags: [String] = []
    var imageFileName: String?
    var dateAdded: Date = Date()
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

enum Category: String, Codable, CaseIterable, Identifiable {
    case clothing = "衣物"
    case kitchen = "厨房"
    case books = "书籍"
    case tools = "工具"
    case electronics = "电子"
    case stationery = "文具"
    case decoration = "装饰"
    case other = "其他"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .kitchen: return "fork.knife"
        case .books: return "book.fill"
        case .tools: return "hammer.fill"
        case .electronics: return "gamecontroller.fill"
        case .stationery: return "pencil"
        case .decoration: return "paintpalette.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing: return .red
        case .kitchen: return .blue
        case .books: return .green
        case .tools: return .purple
        case .electronics: return .yellow
        case .stationery: return .orange
        case .decoration: return .pink
        case .other: return .gray
        }
    }
}
