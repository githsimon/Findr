//
//  ItemListView.swift
//  FindrIOS
//
//  Created on 2025/3/15.
//

import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    
    @Query private var items: [Item]
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedCategory: ItemCategory? = nil
    @State private var selectedItem: Item? = nil
    @State private var showingItemEdit = false
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: Item? = nil
    
    // 标题
    var title: String {
        if let category = selectedCategory {
            return "\(category.rawValue)"
        } else {
            return "物品列表"
        }
    }
    
    // 过滤后的物品
    var filteredItems: [Item] {
        var result = items
        
        // 按分类过滤
        if let category = selectedCategory {
            result = result.filter { $0.category == category.rawValue }
        }
        
        // 按搜索文本过滤
        if !searchText.isEmpty {
            result = result.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.specificLocation.localizedCaseInsensitiveContains(searchText) ||
                item.location?.name.localizedCaseInsensitiveContains(searchText) == true ||
                item.tagNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 按时间排序
        return result.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    init(selectedTab: Binding<Int>, category: ItemCategory? = nil) {
        self._selectedTab = selectedTab
        self._selectedCategory = State(initialValue: category)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索物品...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if filteredItems.isEmpty {
                    ContentUnavailableView("暂无物品", systemImage: "tray", description: Text("添加一些物品来开始使用Findr"))
                        .padding(.top, 40)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ItemRow(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                    showingItemEdit = true
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        itemToDelete = item
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTab = 1 // 切换到添加物品页面
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                if selectedCategory != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("全部物品") {
                            selectedCategory = nil
                        }
                    }
                }
            }
            .sheet(isPresented: $showingItemEdit) {
                if let item = selectedItem {
                    AddItemView(selectedTab: $selectedTab, item: item)
                }
            }
            .alert("确定删除此物品？", isPresented: $showingDeleteAlert) {
                Button("删除", role: .destructive) {
                    if let item = itemToDelete {
                        modelContext.delete(item)
                        try? modelContext.save()
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}

#Preview {
    ItemListView(selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, Tag.self], inMemory: true)
}
