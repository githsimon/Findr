import SwiftUI

// MARK: - Models
struct Item: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var locationId: String
    var photos: [String]
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         locationId: String,
         photos: [String] = [],
         tags: [String] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.locationId = locationId
        self.photos = photos
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - ViewModels
class ItemDetailViewModel: ObservableObject {
    private let item: Item
    @Published var locationName: String = ""
    
    init(item: Item) {
        self.item = item
        self.locationName = "未知位置" // TODO: 从数据存储中获取位置名称
    }
    
    func deleteItem() {
        // TODO: 实现删除逻辑
    }
    
    func updateItem(_ updatedItem: Item) {
        // TODO: 实现更新逻辑
    }
}

// MARK: - Enums
enum SearchFilter: String, CaseIterable, Identifiable, Codable {
    case all
    case name
    case location
    case tags
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .name: return "名称"
        case .location: return "位置"
        case .tags: return "标签"
        }
    }
}

// MARK: - Data Management
class DataManager {
    static let shared = DataManager()
    
    private let itemsFileName = "items.json"
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private init() {}
    
    func saveItems(_ items: [Item]) throws {
        let url = documentsDirectory.appendingPathComponent(itemsFileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(items)
        try data.write(to: url)
    }
    
    func loadItems() throws -> [Item] {
        let url = documentsDirectory.appendingPathComponent(itemsFileName)
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Item].self, from: data)
    }
}
