//
//  SearchView.swift
//  FindrIOS
//
//  Created on 2025/3/15.
//

import SwiftUI
import SwiftData
import Foundation

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedFilter: SearchFilter = .all
    @State private var selectedItem: Item? = nil
    @State private var showingItemEdit = false
    @Binding var selectedTab: Int
    
    // 搜索历史相关
    @State private var searchHistory: [SearchHistory] = []
    @State private var showingSearchHistory = false
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索物品...", text: $searchText)
                        .onSubmit {
                            if !searchText.isEmpty {
                                addSearchHistory(searchText)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .onTapGesture {
                    showingSearchHistory = true
                }
                
                // 筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(SearchFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                
                if searchText.isEmpty && searchHistory.isEmpty {
                    ContentUnavailableView("搜索物品", systemImage: "magnifyingglass", description: Text("输入关键词搜索物品名称、位置或标签"))
                        .padding(.top, 40)
                } else if searchText.isEmpty && !searchHistory.isEmpty {
                    // 显示搜索历史
                    SearchHistoryView(searchHistory: searchHistory, onSelect: { historyItem in
                        searchText = historyItem.query
                        selectedFilter = historyItem.filter
                        addSearchHistory(historyItem.query)
                    }, onClear: {
                        clearSearchHistory()
                    })
                } else {
                    // 搜索结果
                    List {
                        ForEach(filteredItems) { item in
                            ItemRow(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                    showingItemEdit = true
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("搜索")
            .sheet(isPresented: $showingItemEdit) {
                if let item = selectedItem {
                    EditItemView(item: item, selectedTab: $selectedTab)
                }
            }
            .sheet(isPresented: $showingSearchHistory) {
                SearchHistoryView(searchHistory: searchHistory, onSelect: { historyItem in
                    searchText = historyItem.query
                    selectedFilter = historyItem.filter
                    addSearchHistory(historyItem.query)
                    showingSearchHistory = false
                }, onClear: {
                    clearSearchHistory()
                })
                .presentationDetents([.medium])
            }
            .onAppear {
                loadSearchHistory()
            }
        }
    }
    
    // 过滤后的物品
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return []
        }
        
        var result = items.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText) ||
            item.specificLocation.localizedCaseInsensitiveContains(searchText) ||
            item.location?.name.localizedCaseInsensitiveContains(searchText) == true ||
            item.tagNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        // 按筛选器进一步过滤
        switch selectedFilter {
        case .all:
            break // 不做额外过滤
        case .clothing, .kitchen, .books, .tools, .electronics, .stationery, .decoration, .other:
            result = result.filter { $0.category == selectedFilter.rawValue }
        }
        
        return result
    }
    
    // 添加搜索历史
    private func addSearchHistory(_ query: String) {
        // 如果已存在相同查询，则移除旧的
        if let index = searchHistory.firstIndex(where: { $0.query == query }) {
            searchHistory.remove(at: index)
        }
        
        // 添加到历史记录开头
        let newHistory = SearchHistory(query: query, filter: selectedFilter, timestamp: Date())
        searchHistory.insert(newHistory, at: 0)
        
        // 限制历史记录数量
        if searchHistory.count > 10 {
            searchHistory.removeLast()
        }
        
        // 保存到UserDefaults
        saveSearchHistory()
    }
    
    // 清除搜索历史
    private func clearSearchHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
    
    // 保存搜索历史到UserDefaults
    private func saveSearchHistory() {
        if let encoded = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(encoded, forKey: "searchHistory")
        }
    }
    
    // 从UserDefaults加载搜索历史
    private func loadSearchHistory() {
        if let savedHistory = UserDefaults.standard.data(forKey: "searchHistory"),
           let decodedHistory = try? JSONDecoder().decode([SearchHistory].self, from: savedHistory) {
            searchHistory = decodedHistory
        }
    }
}

// 搜索历史视图
struct SearchHistoryView: View {
    let searchHistory: [SearchHistory]
    let onSelect: (SearchHistory) -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("搜索历史")
                    .font(.headline)
                Spacer()
                Button("清除") {
                    onClear()
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if searchHistory.isEmpty {
                ContentUnavailableView("无搜索历史", systemImage: "clock", description: Text("您的搜索历史将显示在这里"))
                    .padding(.top, 40)
            } else {
                List {
                    ForEach(searchHistory) { historyItem in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text(historyItem.query)
                            
                            if historyItem.filter != .all {
                                Text(historyItem.filter.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            Text(formattedDate(historyItem.timestamp))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(historyItem)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    SearchView(selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, Tag.self], inMemory: true)
}
