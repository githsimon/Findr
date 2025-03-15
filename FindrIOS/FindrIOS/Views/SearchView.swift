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
    @State private var searchHistory: [FindrIOS.SearchHistory] = []
    @State private var showingSearchHistory = false
    
    // 下拉刷新相关
    @State private var isRefreshing = false
    @State private var showAllItems = false // 控制是否显示所有物品
    
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
                                // 如果搜索框为空，则显示所有物品
                                if searchText.isEmpty {
                                    showAllItems = true
                                }
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
                
                if searchText.isEmpty && !showAllItems && searchHistory.isEmpty {
                    ContentUnavailableView("搜索物品", systemImage: "magnifyingglass", description: Text("输入关键词搜索物品名称、位置或标签或点击分类按钮查看所有物品"))
                        .padding(.top, 40)
                } else if searchText.isEmpty && !showAllItems && !searchHistory.isEmpty {
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
                    .refreshable {
                        // 模拟刷新操作
                        isRefreshing = true
                        // 延迟1秒模拟刷新
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isRefreshing = false
                        }
                    }
                    .overlay {
                        if filteredItems.isEmpty {
                            ContentUnavailableView("没有找到物品", systemImage: "magnifyingglass", description: Text("尝试使用不同的关键词或分类进行搜索"))
                        }
                    }
                }
            }
            .navigationTitle("搜索")
            .sheet(isPresented: $showingItemEdit) {
                if let item = selectedItem {
                    AddItemView(selectedTab: $selectedTab, item: item)
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
                .presentationDetents([.medium]) // 修复presentationDetents的使用
            }
            .onAppear {
                loadSearchHistory()
            }
        }
    }
    
    // 过滤后的物品
    var filteredItems: [Item] {
        // 如果搜索文本为空且不显示所有物品，则返回空数组
        if searchText.isEmpty && !showAllItems {
            return []
        }
        
        var result = items
        
        // 如果有搜索文本，按搜索文本过滤
        if !searchText.isEmpty {
            result = result.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.specificLocation.localizedCaseInsensitiveContains(searchText) ||
                item.location?.name.localizedCaseInsensitiveContains(searchText) == true ||
                item.tagNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 按筛选器进一步过滤
        switch selectedFilter {
        case .all:
            break // 不做额外过滤
        case .clothing, .kitchen, .books, .tools, .electronics, .stationery, .decoration, .other:
            result = result.filter { $0.category == selectedFilter.rawValue }
        }
        
        // 按时间排序，最新的在前
        return result.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    // 添加搜索历史
    private func addSearchHistory(_ query: String) {
        // 如果已存在相同查询，则移除旧的
        if let index = searchHistory.firstIndex(where: { $0.query == query }) {
            searchHistory.remove(at: index)
        }
        
        // 添加到历史记录开头
        let newHistory = FindrIOS.SearchHistory(query: query, filter: selectedFilter, timestamp: Date())
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
    
    // 从 UserDefaults 加载搜索历史
    private func loadSearchHistory() {
        if let savedHistory = UserDefaults.standard.data(forKey: "searchHistory"),
           let decodedHistory = try? JSONDecoder().decode([FindrIOS.SearchHistory].self, from: savedHistory) {
            searchHistory = decodedHistory
        }
    }
}

// 搜索历史视图
struct SearchHistoryView: View {
    let searchHistory: [FindrIOS.SearchHistory]
    let onSelect: (FindrIOS.SearchHistory) -> Void
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
            .padding(.top)
            
            if searchHistory.isEmpty {
                Text("暂无搜索历史")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(0..<searchHistory.count, id: \.self) { index in
                            let history = searchHistory[index]
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                VStack(alignment: .leading) {
                                    Text(history.query)
                                    Text(history.filter.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(history.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .onTapGesture {
                                onSelect(history)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom)
    }
}

#Preview {
    SearchView(selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, Tag.self], inMemory: true)
}
