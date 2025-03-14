import Foundation
import SwiftUI

struct Item: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: Category
    var locationId: UUID
    var specificLocation: String
    var notes: String
    var tags: [String]
    var imageName: String?
    var dateAdded: Date
    
    enum Category: String, Codable, CaseIterable {
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
            case .clothing: return "tshirt"
            case .kitchen: return "fork.knife"
            case .books: return "book"
            case .tools: return "hammer"
            case .electronics: return "gamecontroller"
            case .stationery: return "pencil"
            case .decoration: return "photo.artframe"
            case .other: return "square.grid.2x2"
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
}
