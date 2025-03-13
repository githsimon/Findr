import SwiftUI
import PhotosUI

@MainActor
class AddItemViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var locationId = ""
    @Published var photos: [UIImage] = []
    @Published var tags: [String] = []
    
    var isValid: Bool {
        !name.isEmpty && !locationId.isEmpty
    }
    
    func loadPhotos(from selectedItems: [PhotosPickerItem]) async {
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    photos.append(image)
                }
            }
        }
    }
    
    func removePhoto(at index: Int) {
        photos.remove(at: index)
    }
    
    func createItem() -> Item? {
        guard isValid else { return nil }
        
        // TODO: 处理照片保存逻辑，目前仅返回空数组
        return Item(
            name: name,
            description: description,
            locationId: locationId,
            photos: [], // TODO: 实现照片保存
            tags: tags
        )
    }
}
