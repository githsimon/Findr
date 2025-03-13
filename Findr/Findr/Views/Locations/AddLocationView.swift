import SwiftUI

struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LocationViewModel
    @State private var name = ""
    @State private var type: LocationType = .room
    @State private var description = ""
    @State private var parentLocation: Location?
    
    private var availableParentLocations: [Location] {
        switch type {
        case .room:
            return [] // 房间不能有父位置
        case .cabinet, .drawer, .shelf:
            return viewModel.getRoomLocations() // 只能选择房间作为父位置
        case .other:
            return viewModel.locations // 可以选择任何位置作为父位置
        }
    }
    
    private var isValid: Bool {
        let nameValid = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let descriptionValid = !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // 如果是房间类型，不需要父位置；其他类型必须选择父位置
        let parentValid = type == .room ? true : parentLocation != nil
        
        return nameValid && descriptionValid && parentValid
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("名称", text: $name)
                        .textInputAutocapitalization(.never)
                    Picker("类型", selection: $type) {
                        ForEach(LocationType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("位置信息")
                } footer: {
                    if name.isEmpty {
                        Text("请输入位置名称")
                            .foregroundColor(.red)
                    }
                    if description.isEmpty {
                        Text("请输入位置描述")
                            .foregroundColor(.red)
                    }
                }
                
                if type != .room {
                    Section {
                        Picker("选择上级位置", selection: $parentLocation) {
                            Text("请选择").tag(nil as Location?)
                            ForEach(availableParentLocations) { location in
                                Text(location.name).tag(location as Location?)
                            }
                        }
                    } header: {
                        Text("上级位置")
                    } footer: {
                        if parentLocation == nil {
                            Text("请选择上级位置")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("添加位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let newLocation = Location(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            type: type,
                            parentId: parentLocation?.id,
                            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        viewModel.addLocation(newLocation)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onChange(of: type) { _ in
                // 如果切换类型，重置父位置选择
                parentLocation = nil
            }
        }
    }
}

#Preview {
    AddLocationView()
        .environmentObject(LocationViewModel())
}
