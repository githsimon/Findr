import SwiftUI

struct EditItemView: View {
    let item: Item
    let viewModel: ItemDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var locationId: String
    @State private var tags: [String]
    
    init(item: Item, viewModel: ItemDetailViewModel) {
        self.item = item
        self.viewModel = viewModel
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description)
        _locationId = State(initialValue: item.locationId)
        _tags = State(initialValue: item.tags)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("名称", text: $name)
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("位置") {
                    LocationPickerView(selectedLocationId: $locationId)
                }
                
                Section("标签") {
                    TagInputView(tags: $tags)
                }
            }
            .navigationTitle("编辑物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        let updatedItem = Item(
            id: item.id,
            name: name,
            description: description,
            locationId: locationId,
            photos: item.photos,
            tags: tags,
            createdAt: item.createdAt,
            updatedAt: Date()
        )
        viewModel.updateItem(updatedItem)
        dismiss()
    }
}

#Preview {
    EditItemView(
        item: Item(
            name: "测试物品",
            description: "这是一个测试物品",
            locationId: "test_location",
            tags: ["测试", "示例"]
        ),
        viewModel: ItemDetailViewModel(
            item: Item(
                name: "测试物品",
                description: "这是一个测试物品",
                locationId: "test_location",
                tags: ["测试", "示例"]
            )
        )
    )
}
