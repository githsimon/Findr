import SwiftUI
import PhotosUI

struct AddItemView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    @State private var itemName = ""
    @State private var selectedCategory: Item.Category = .clothing
    @State private var selectedLocationId: UUID? = nil
    @State private var specificLocation = ""
    @State private var notes = ""
    @State private var tags: [String] = []
    @State private var tagInput = ""
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Photo Section
                Section(header: Text("物品照片")) {
                    VStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(10)
                        } else {
                            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                    Text("点击添加照片")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        
                        if selectedImage != nil {
                            Button("移除照片") {
                                selectedImage = nil
                                photoPickerItem = nil
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                        }
                    }
                    .onChange(of: photoPickerItem) { newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                }
                
                // Item Information
                Section(header: Text("物品信息")) {
                    TextField("物品名称", text: $itemName)
                    
                    Picker("分类", selection: $selectedCategory) {
                        ForEach(Item.Category.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                // Location Section
                Section(header: Text("存放位置")) {
                    Picker("位置", selection: $selectedLocationId) {
                        Text("选择位置").tag(nil as UUID?)
                        ForEach(locationStore.locations) { location in
                            Text(location.name).tag(location.id as UUID?)
                        }
                    }
                    
                    if let locationId = selectedLocationId,
                       let location = locationStore.getLocationById(locationId),
                       !location.sublocations.isEmpty {
                        Picker("子位置", selection: $specificLocation) {
                            Text("选择子位置").tag("")
                            ForEach(location.sublocations) { sublocation in
                                Text(sublocation.name).tag(sublocation.name)
                            }
                        }
                    } else {
                        TextField("具体位置", text: $specificLocation)
                    }
                }
                
                // Notes Section
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                // Tags Section
                Section(header: Text("标签")) {
                    HStack {
                        TextField("添加标签", text: $tagInput)
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                            .font(.caption)
                                        
                                        Button(action: {
                                            removeTag(tag)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(15)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("添加物品")
            .navigationBarItems(
                leading: Button("取消") {
                    clearForm()
                },
                trailing: Button("保存") {
                    saveItem()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
    }
    
    private var isFormValid: Bool {
        !itemName.isEmpty && selectedLocationId != nil
    }
    
    private func addTag() {
        let trimmedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
        }
    }
    
    private func saveItem() {
        guard let locationId = selectedLocationId else {
            alertMessage = "请选择存放位置"
            showingAlert = true
            return
        }
        
        // Save image to documents directory and get filename
        var imageName: String? = nil
        if let image = selectedImage {
            imageName = saveImageToDocuments(image)
        }
        
        let newItem = Item(
            name: itemName,
            category: selectedCategory,
            locationId: locationId,
            specificLocation: specificLocation,
            notes: notes,
            tags: tags,
            imageName: imageName,
            dateAdded: Date()
        )
        
        itemStore.addItem(newItem)
        itemStore.saveItemsToFile() // Save to JSON file
        
        // Show success message
        alertMessage = "物品已保存"
        showingAlert = true
        
        // Clear form
        clearForm()
    }
    
    private func clearForm() {
        itemName = ""
        selectedCategory = .clothing
        selectedLocationId = nil
        specificLocation = ""
        notes = ""
        tags = []
        tagInput = ""
        selectedImage = nil
        photoPickerItem = nil
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

#Preview {
    AddItemView()
        .environmentObject(ItemStore())
        .environmentObject(LocationStore())
}
