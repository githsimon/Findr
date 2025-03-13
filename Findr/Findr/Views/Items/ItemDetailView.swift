import SwiftUI

// MARK: - ItemDetailView
struct ItemDetailView: View {
    let item: Item
    @StateObject private var viewModel: ItemDetailViewModel
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    init(item: Item) {
        self.item = item
        self._viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 照片画廊
                PhotoGalleryView(photos: item.photos)
                
                // 基本信息
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "名称", content: item.name)
                    InfoRow(title: "位置", content: viewModel.locationName)
                    InfoRow(title: "描述", content: item.description)
                    
                    // 标签云
                    TagCloudView(tags: item.tags)
                }
                .padding()
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("编辑", action: { isEditing = true })
                    Button("删除", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                viewModel.deleteItem()
                dismiss()
            }
        } message: {
            Text("确定要删除这个物品吗？此操作不可撤销。")
        }
        .sheet(isPresented: $isEditing) {
            EditItemView(item: item, viewModel: viewModel)
        }
    }
}

// MARK: - Supporting Views
private struct PhotoGalleryView: View {
    let photos: [String]
    @State private var selectedPhotoIndex = 0
    
    var body: some View {
        TabView(selection: $selectedPhotoIndex) {
            if photos.isEmpty {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .foregroundColor(.gray)
            } else {
                ForEach(photos.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: photos[index])) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
    }
}

private struct InfoRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(content)
                .font(.body)
        }
    }
}

private struct TagCloudView: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("标签")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Preview
struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemDetailView(
                item: Item(
                    name: "测试物品",
                    description: "这是一个测试物品",
                    locationId: "test_location",
                    tags: ["测试", "示例"]
                )
            )
        }
    }
}
