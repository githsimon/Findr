import SwiftUI

struct SearchView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    @StateObject private var viewModel = SearchViewModel()
    @State private var showingFilterSheet = false
    @State private var showingSearchHistory = false
    
    var filteredItems: [Item] {
        viewModel.filterItems(items: itemStore.items)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("搜索物品...", text: $viewModel.searchText)
                            .font(.system(size: 17))
                            .onSubmit {
                                if !viewModel.searchText.isEmpty {
                                    viewModel.addToSearchHistory(viewModel.searchText)
                                }
                            }
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Button(action: {
                                showingSearchHistory = true
                            }) {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Search Results or Empty State
                if viewModel.searchText.isEmpty && viewModel.activeFilter == .none {
                    SearchEmptyStateView()
                } else {
                    if filteredItems.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("未找到匹配的物品")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("尝试使用不同的关键词或筛选条件")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(filteredItems) { item in
                                SearchResultRow(item: item)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationTitle("搜索")
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSearchHistory) {
                SearchHistoryView(viewModel: viewModel, isPresented: $showingSearchHistory)
            }
        }
    }
}

struct SearchEmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("搜索您的物品")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("输入关键词或使用筛选条件查找物品")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct SearchResultRow: View {
    let item: Item
    @EnvironmentObject var locationStore: LocationStore
    
    var locationName: String {
        if let location = locationStore.locations.first(where: { $0.id == item.locationID }) {
            if let sublocation = item.sublocationName {
                if let specific = item.specificLocation {
                    return "\(location.name) - \(sublocation) - \(specific)"
                }
                return "\(location.name) - \(sublocation)"
            }
            return location.name
        }
        return "未知位置"
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(item.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: item.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(item.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(locationName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(item.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 24)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct FilterSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("分类")) {
                    ForEach(Category.allCases) { category in
                        Button(action: {
                            viewModel.toggleCategoryFilter(category)
                        }) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                
                                Text(category.rawValue)
                                
                                Spacer()
                                
                                if viewModel.selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("位置")) {
                    Picker("按位置筛选", selection: $viewModel.selectedLocationID) {
                        Text("所有位置").tag(nil as UUID?)
                        ForEach(viewModel.availableLocations) { location in
                            Text(location.name).tag(location.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("排序方式")) {
                    Picker("排序", selection: $viewModel.sortOption) {
                        Text("名称 (A-Z)").tag(SortOption.nameAsc)
                        Text("名称 (Z-A)").tag(SortOption.nameDesc)
                        Text("最新添加").tag(SortOption.newest)
                        Text("最早添加").tag(SortOption.oldest)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: {
                        viewModel.resetFilters()
                    }) {
                        Text("重置筛选条件")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("筛选")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SearchHistoryView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.searchHistory.isEmpty {
                    Text("暂无搜索历史")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.searchHistory) { historyItem in
                        Button(action: {
                            viewModel.searchText = historyItem.query
                            isPresented = false
                        }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                
                                Text(historyItem.query)
                                
                                Spacer()
                                
                                Text(formatDate(historyItem.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .onDelete(perform: viewModel.deleteSearchHistory)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("搜索历史")
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                },
                trailing: Button("清空") {
                    viewModel.clearSearchHistory()
                }
                .disabled(viewModel.searchHistory.isEmpty)
            )
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ItemStore())
            .environmentObject(LocationStore())
    }
}
