import SwiftUI

class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    init() {
        loadItems()
    }
    
    func addItem(_ item: Item) {
        items.append(item)
        saveItems()
    }
    
    func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    private func loadItems() {
        do {
            items = try DataManager.shared.loadItems()
        } catch {
            print("加载物品失败：\\(error)")
        }
    }
    
    private func saveItems() {
        do {
            try DataManager.shared.saveItems(items)
        } catch {
            print("保存物品失败：\\(error)")
        }
    }
}
