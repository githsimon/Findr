import Foundation
import SwiftUI

class ItemStore: ObservableObject {
    @Published var items: [Item] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let itemsKey = "savedItems"
    
    init() {
        loadItems()
    }
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func deleteItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    
    func deleteItem(withId id: UUID) {
        if let index = items.firstIndex(where: { $item in $item.id == id }) {
            items.remove(at: index)
        }
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $item in $item.id == item.id }) {
            items[index] = item
        }
    }
    
    func getItemsByLocation(locationId: UUID) -> [Item] {
        return items.filter { $0.locationId == locationId }
    }
    
    func getItemsByCategory(category: Item.Category) -> [Item] {
        return items.filter { $0.category == category }
    }
    
    func getRecentItems(limit: Int = 5) -> [Item] {
        return Array(items.sorted(by: { $0.dateAdded > $1.dateAdded }).prefix(limit))
    }
    
    private func saveItems() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: itemsKey) else { 
            // Load sample data if no saved data exists
            loadSampleData()
            return 
        }
        
        if let decodedItems = try? JSONDecoder().decode([Item].self, from: data) {
            items = decodedItems
        }
    }
    
    private func loadSampleData() {
        // Create sample data for preview and first launch
        let sampleItems: [Item] = [
            Item(
                name: "冬季毛衣",
                category: .clothing,
                locationId: UUID(), // This will be replaced with actual location ID
                specificLocation: "第二层",
                notes: "红色羊毛毛衣",
                tags: ["冬季", "保暖"],
                imageName: nil,
                dateAdded: Date().addingTimeInterval(-86400) // 1 day ago
            ),
            Item(
                name: "烘焙工具套装",
                category: .kitchen,
                locationId: UUID(),
                specificLocation: "右侧第一个抽屉",
                notes: "包含量杯、刮刀和裱花袋",
                tags: ["烘焙", "工具"],
                imageName: nil,
                dateAdded: Date().addingTimeInterval(-172800) // 2 days ago
            ),
            Item(
                name: "相机配件",
                category: .electronics,
                locationId: UUID(),
                specificLocation: "书桌抽屉",
                notes: "镜头盖、清洁布和备用电池",
                tags: ["相机", "配件"],
                imageName: nil,
                dateAdded: Date().addingTimeInterval(-259200) // 3 days ago
            )
        ]
        
        items = sampleItems
    }
    
    // Save items to a JSON file in the Documents directory
    func saveItemsToFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(items)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("items.json")
            try data.write(to: fileURL)
            print("Items saved to: \(fileURL.path)")
        } catch {
            print("Error saving items to file: \(error)")
        }
    }
    
    // Load items from a JSON file in the Documents directory
    func loadItemsFromFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("items.json")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                items = try decoder.decode([Item].self, from: data)
                print("Items loaded from: \(fileURL.path)")
            } catch {
                print("Error loading items from file: \(error)")
            }
        }
    }
}
