import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    
    @State private var name = ""
    @State private var selectedCategory: Category = .clothing
    @State private var selectedLocationID: UUID?
    @State private var sublocationName = ""
    @State private var specificLocation = ""
    @State private var notes = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var imageFileName: String?
    
    var body: some View {
        NavigationView {
            Form {
                // Photo Section
                Section(header: Text("物品照片")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Spacer()
                            
                            if let inputImage = inputImage {
                                Image(uiImage: inputImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(8)
                            } else {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 8)
                                    
                                    Text("点击添加照片")
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Item Info Section
                Section(header: Text("物品信息")) {
                    TextField("物品名称", text: $name)
                    
                    Picker("分类", selection: $selectedCategory) {
                        ForEach(Category.allCases) { category in
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
                    if locationStore.locations.isEmpty {
                        Text("请先添加位置")
                            .foregroundColor(.gray)
                    } else {
                        Picker("位置", selection: $selectedLocationID) {
                            Text("请选择位置").tag(nil as UUID?)
                            ForEach(locationStore.locations) { location in
                                Text(location.name).tag(location.id as UUID?)
                            }
                        }
                        
                        if let locationID = selectedLocationID,
                           let location = locationStore.locations.first(where: { $0.id == locationID }),
                           !location.sublocations.isEmpty {
                            Picker("子位置", selection: $sublocationName) {
                                Text("请选择子位置").tag("")
                                ForEach(location.sublocations) { sublocation in
                                    Text(sublocation.name).tag(sublocation.name)
                                }
                            }
                        } else {
                            TextField("子位置", text: $sublocationName)
                        }
                        
                        TextField("具体位置", text: $specificLocation)
                            .font(.body)
                            .foregroundColor(.primary)
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
                        .disabled(tagInput.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.leading, 8)
                                            .padding(.trailing, 0)
                                        
                                        Button(action: {
                                            removeTag(tag)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(15)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("添加物品")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveItem()
                }
                .disabled(name.isEmpty || selectedLocationID == nil)
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    func addTag() {
        let newTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newTag.isEmpty && !tags.contains(newTag) {
            tags.append(newTag)
            tagInput = ""
        }
    }
    
    func removeTag(_ tag: String) {
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
        }
    }
    
    func saveItem() {
        guard let locationID = selectedLocationID else { return }
        
        // Save image if exists
        if let inputImage = inputImage {
            imageFileName = saveImage(inputImage)
        }
        
        let newItem = Item(
            name: name,
            category: selectedCategory,
            locationID: locationID,
            sublocationName: sublocationName.isEmpty ? nil : sublocationName,
            specificLocation: specificLocation.isEmpty ? nil : specificLocation,
            notes: notes.isEmpty ? nil : notes,
            tags: tags,
            imageFileName: imageFileName
        )
        
        itemStore.addItem(newItem)
        
        // Update item count in location
        if let index = locationStore.locations.firstIndex(where: { $0.id == locationID }) {
            var updatedLocation = locationStore.locations[index]
            updatedLocation.itemCount += 1
            
            // Update sublocation item count if applicable
            if !sublocationName.isEmpty {
                if let sublocationIndex = updatedLocation.sublocations.firstIndex(where: { $0.name == sublocationName }) {
                    updatedLocation.sublocations[sublocationIndex].itemCount += 1
                } else {
                    // Add new sublocation if it doesn't exist
                    updatedLocation.sublocations.append(Sublocation(name: sublocationName, itemCount: 1))
                }
            }
            
            locationStore.updateLocation(updatedLocation)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func saveImage(_ image: UIImage) -> String {
        let fileName = UUID().uuidString
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            return fileName
        }
        
        return ""
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
            .environmentObject(ItemStore())
            .environmentObject(LocationStore())
    }
}
