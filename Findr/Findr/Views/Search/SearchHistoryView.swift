import SwiftUI

struct SearchHistoryView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("搜索历史")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.searchHistory.isEmpty {
                    Button(action: {
                        viewModel.clearSearchHistory()
                    }) {
                        Text("清除")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.searchHistory.isEmpty {
                Text("暂无搜索历史")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.searchHistory) { historyItem in
                            SearchHistoryItemView(
                                historyItem: historyItem,
                                onSelect: {
                                    viewModel.selectSearchHistoryItem(historyItem)
                                },
                                onRemove: {
                                    viewModel.removeSearchHistoryItem(historyItem)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct SearchHistoryItemView: View {
    let historyItem: SearchHistory
    let onSelect: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(historyItem.keyword)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer(minLength: 4)
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            HStack {
                Text(historyItem.filter.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(historyItem.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    SearchHistoryView(viewModel: SearchViewModel())
        .padding()
}
