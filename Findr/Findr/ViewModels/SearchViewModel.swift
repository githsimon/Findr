import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedFilter: SearchFilter = .all
    @Published private(set) var searchResults: [Item] = []
    @Published private(set) var searchHistory: [SearchHistory] = []
    
    private let historyKey = "SearchHistoryKey"
    
    // 加载搜索历史
    private func loadSearchHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let history = try? JSONDecoder().decode([SearchHistory].self, from: data) {
            searchHistory = history
        }
    }
    
    // 保存搜索历史
    private func saveSearchHistory() {
        if let data = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    // 添加新的搜索记录
    func addSearchHistory(text: String, filter: SearchFilter) {
        // 只有当搜索文本不为空时才添加到历史记录
        guard !text.isEmpty else { return }
        
        let newHistory = SearchHistory(
            id: UUID(),
            keyword: text, 
            filter: filter, 
            date: Date()
        )
        
        // 移除重复记录
        searchHistory.removeAll { $0.keyword == text && $0.filter == filter }
        searchHistory.insert(newHistory, at: 0)
        
        // 保留最近10条记录
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }
        
        saveSearchHistory()
    }
    
    // 清除所有搜索历史
    func clearSearchHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
    
    // 从历史记录中选择一个搜索条目
    func selectSearchHistoryItem(_ historyItem: SearchHistory) {
        searchText = historyItem.keyword
        selectedFilter = historyItem.filter
    }
    
    // 删除特定的搜索历史记录
    func removeSearchHistoryItem(_ historyItem: SearchHistory) {
        searchHistory.removeAll { $0.id == historyItem.id }
        saveSearchHistory()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 加载搜索历史
        loadSearchHistory()
        
        // 监听搜索文本和过滤器的变化
        Publishers.CombineLatest($searchText, $selectedFilter)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text, filter in
                guard let self = self else { return }
                self.performSearch(text: text, filter: filter)
                
                // 只有当搜索文本不为空时才添加到历史记录
                if !text.isEmpty {
                    self.addSearchHistory(text: text, filter: filter)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(text: String, filter: SearchFilter) {
        guard !text.isEmpty else {
            searchResults = []
            return
        }
        
        // TODO: 实现实际的搜索逻辑
        do {
            let allItems = try DataManager.shared.loadItems()
            let lowercasedText = text.lowercased()
            
            searchResults = allItems.filter { item in
                switch filter {
                case .all:
                    return item.name.lowercased().contains(lowercasedText) ||
                           item.description.lowercased().contains(lowercasedText) ||
                           item.tags.contains { $0.lowercased().contains(lowercasedText) } ||
                           item.locationId.lowercased().contains(lowercasedText)
                case .name:
                    return item.name.lowercased().contains(lowercasedText)
                case .location:
                    return item.locationId.lowercased().contains(lowercasedText)
                case .tags:
                    return item.tags.contains { $0.lowercased().contains(lowercasedText) }
                }
            }
        } catch {
            print("搜索出错：\(error.localizedDescription)")
            searchResults = []
        }
    }
}
