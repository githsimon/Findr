import Foundation
import SwiftUI

enum SearchFilter: String, Codable {
    case none = "无筛选"
    case category = "分类"
    case location = "位置"
    case tag = "标签"
}

enum SortOption: String, Codable {
    case nameAsc = "名称升序"
    case nameDesc = "名称降序"
    case newest = "最新添加"
    case oldest = "最早添加"
}

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategories: [Category] = []
    @Published var selectedLocationID: UUID?
    @Published var selectedTags: [String] = []
    @Published var sortOption: SortOption = .newest
    @Published var activeFilter: SearchFilter = .none
    @Published var searchHistory: [SearchHistory] = []
    
    var availableLocations: [Location] {
        LocationStore().locations
    }
    
    init() {
        loadSearchHistory()
    }
    
    func filterItems(items: [Item]) -> [Item] {
        var filteredItems = items
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredItems = filteredItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                (item.notes ?? "").localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by categories
        if !selectedCategories.isEmpty {
            filteredItems = filteredItems.filter { selectedCategories.contains($0.category) }
            activeFilter = .category
        }
        
        // Filter by location
        if let locationID = selectedLocationID {
            filteredItems = filteredItems.filter { $0.locationID == locationID }
            activeFilter = .location
        }
        
        // Filter by tags
        if !selectedTags.isEmpty {
            filteredItems = filteredItems.filter { item in
                !Set(item.tags).isDisjoint(with: Set(selectedTags))
            }
            activeFilter = .tag
        }
        
        // Sort items
        switch sortOption {
        case .nameAsc:
            filteredItems.sort { $0.name < $1.name }
        case .nameDesc:
            filteredItems.sort { $0.name > $1.name }
        case .newest:
            filteredItems.sort { $0.dateAdded > $1.dateAdded }
        case .oldest:
            filteredItems.sort { $0.dateAdded < $1.dateAdded }
        }
        
        return filteredItems
    }
    
    func toggleCategoryFilter(_ category: Category) {
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(category)
        }
        
        if selectedCategories.isEmpty && selectedLocationID == nil && selectedTags.isEmpty {
            activeFilter = .none
        } else {
            activeFilter = .category
        }
    }
    
    func resetFilters() {
        selectedCategories = []
        selectedLocationID = nil
        selectedTags = []
        sortOption = .newest
        activeFilter = .none
    }
    
    // MARK: - Search History
    
    private static func fileURL() -> URL {
        try! FileManager.default.url(for: .documentDirectory, 
                                     in: .userDomainMask, 
                                     appropriateFor: nil, 
                                     create: true)
            .appendingPathComponent("searchHistory.json")
    }
    
    func loadSearchHistory() {
        let fileURL = Self.fileURL()
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                searchHistory = try decoder.decode([SearchHistory].self, from: data)
            } catch {
                print("Failed to load search history: \(error)")
                searchHistory = []
            }
        }
    }
    
    func saveSearchHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(searchHistory)
            try data.write(to: Self.fileURL())
        } catch {
            print("Failed to save search history: \(error)")
        }
    }
    
    func addToSearchHistory(_ query: String) {
        // Check if the query already exists
        if let index = searchHistory.firstIndex(where: { $0.query == query }) {
            // Update the date
            searchHistory[index].date = Date()
            
            // Move to the top
            let item = searchHistory.remove(at: index)
            searchHistory.insert(item, at: 0)
        } else {
            // Add new query
            let newItem = SearchHistory(query: query)
            searchHistory.insert(newItem, at: 0)
            
            // Limit history to 20 items
            if searchHistory.count > 20 {
                searchHistory.removeLast()
            }
        }
        
        saveSearchHistory()
    }
    
    func deleteSearchHistory(at offsets: IndexSet) {
        searchHistory.remove(atOffsets: offsets)
        saveSearchHistory()
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
}
