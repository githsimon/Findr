import SwiftUI
import PhotosUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddItemViewModel()
    @EnvironmentObject var listViewModel: ItemListViewModel
    @State private var showingImagePicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("物品名称", text: $viewModel.name)
                    TextField("描述", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("位置")) {
                    LocationPickerView(selectedLocationId: $viewModel.locationId)
                }
                
                Section(header: Text("照片")) {
                    PhotosPicker(selection: $selectedItems,
                               matching: .images,
                               photoLibrary: .shared()) {
                        Label("选择照片", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(viewModel.photos.indices, id: \.self) { index in
                                Image(uiImage: viewModel.photos[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        Button(action: { viewModel.removePhoto(at: index) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .red)
                                        }
                                        .padding(4),
                                        alignment: .topTrailing
                                    )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(height: viewModel.photos.isEmpty ? 0 : 108)
                }
                
                Section(header: Text("标签")) {
                    TagInputView(tags: $viewModel.tags)
                }
            }
            .navigationTitle("添加物品")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    if let newItem = viewModel.createItem() {
                        listViewModel.addItem(newItem)
                        dismiss()
                    }
                }
                .disabled(!viewModel.isValid)
            )
            .onChange(of: selectedItems) { newValue in
                Task {
                    await viewModel.loadPhotos(from: newValue)
                }
            }
        }
    }
}
