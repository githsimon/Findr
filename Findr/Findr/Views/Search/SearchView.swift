import SwiftUI

@MainActor
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                // 搜索过滤器
                Picker("搜索范围", selection: $viewModel.selectedFilter) {
                    ForEach(SearchFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 搜索历史
                if viewModel.searchText.isEmpty {
                    SearchHistoryView(viewModel: viewModel)
                }
                
                // 搜索结果
                List {
                    ForEach(viewModel.searchResults) { item in
                        SearchResultRow(item: item)
                    }
                }
                .overlay {
                    if viewModel.searchResults.isEmpty {
                        ContentUnavailableView(
                            label: {
                                Label(
                                    viewModel.searchText.isEmpty ? "搜索物品" : "未找到结果",
                                    systemImage: viewModel.searchText.isEmpty ? "magnifyingglass" : "exclamationmark.magnifyingglass"
                                )
                            },
                            description: {
                                Text(viewModel.searchText.isEmpty ? "输入关键词开始搜索" : "尝试其他搜索词或更改过滤条件")
                            }
                        )
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "搜索物品")
            .navigationTitle("搜索")
        }
    }
}

private struct SearchResultRow: View {
    let item: Item
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(item: item)) {
            HStack(spacing: 12) {
                // 物品缩略图
                if let firstPhotoUrl = item.photos.first {
                    AsyncImage(url: URL(string: firstPhotoUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    if !item.tags.isEmpty {
                        HStack {
                            ForEach(item.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            if item.tags.count > 3 {
                                Text("+\(item.tags.count - 3)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    SearchView()
}
