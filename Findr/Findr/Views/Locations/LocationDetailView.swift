import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @ObservedObject var viewModel: LocationViewModel
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedType: LocationType = .room
    
    var body: some View {
        List {
            Section(header: Text("基本信息")) {
                if isEditing {
                    TextField("名称", text: $editedName)
                    Picker("类型", selection: $editedType) {
                        ForEach(LocationType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                } else {
                    LabeledContent("名称", value: location.name)
                    LabeledContent("类型", value: location.type.displayName)
                }
            }
            
            if let parentName = viewModel.getParentLocationName(for: location) {
                Section(header: Text("所属位置")) {
                    Text(parentName)
                }
            }
            
            Section(header: Text("包含的物品")) {
                // TODO: 显示该位置下的物品列表
                Text("暂无物品")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle(location.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "保存" : "编辑") {
                    if isEditing {
                        viewModel.updateLocation(location.id, name: editedName, type: editedType)
                    } else {
                        editedName = location.name
                        editedType = location.type
                    }
                    isEditing.toggle()
                }
            }
        }
    }
}
