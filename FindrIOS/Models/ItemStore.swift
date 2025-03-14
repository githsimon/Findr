import Foundation
import SwiftUI

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    
    private static func fileURL() -> URL {
        try! FileManager.default.url(for: .documentDirectory, 
                                     in: .userDomainMask, 
                                     appropriateFor: nil, 
                                     create: true)
            .appendingPathComponent("items.json")
    }
    
    init() {
        loadItems()
    }
    
    func loadItems() {
        let fileURL = Self.fileURL()
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("Failed to load items: \(error)")
                // Initialize with sample data if loading fails
                items = sampleItems
            }
        } else {
            // Initialize with sample data for first launch
            items = sampleItems
            saveItems()
        }
    }
    
    func saveItems() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            try data.write(to: Self.fileURL())
        } catch {
            print("Failed to save items: \(error)")
        }
    }
    
    func addItem(_ item: Item) {
        items.append(item)
        saveItems()
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }
    
    func deleteItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
        saveItems()
    }
    
    func deleteItem(withID id: UUID) {
        items.removeAll(where: { $0.id == id })
        saveItems()
    }
    
    func getItemsByLocation(locationID: UUID) -> [Item] {
        return items.filter { $0.locationID == locationID }
    }
    
    func getRecentItems(limit: Int = 5) -> [Item] {
        return Array(items.sorted(by: { $0.dateAdded > $1.dateAdded }).prefix(limit))
    }
    
    // Sample data for testing and first launch
    private var sampleItems: [Item] = {
        // This assumes we have the sample locations defined in LocationStore
        // We'll use placeholder UUIDs for now
        let locationIDs = [UUID(), UUID(), UUID(), UUID(), UUID()]
        
        return [
            Item(name: "冬季毛衣", 
                 category: .clothing, 
                 locationID: locationIDs[0], 
                 sublocationName: "衣柜", 
                 specificLocation: "第二层",
                 tags: ["冬季", "毛衣"]),
                 
            Item(name: "烘焙工具套装", 
                 category: .kitchen, 
                 locationID: locationIDs[1], 
                 sublocationName: "下柜", 
                 specificLocation: "右侧第一个抽屉",
                 tags: ["烘焙", "工具"]),
                 
            Item(name: "相机配件", 
                 category: .electronics, 
                 locationID: locationIDs[3], 
                 sublocationName: "书桌", 
                 specificLocation: "抽屉",
                 tags: ["相机", "配件"])
        ]
    }()
}
