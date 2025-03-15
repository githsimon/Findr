//
//  LocationsView.swift
//  FindrIOS
//
//  Created on 2025/3/14.
//

import SwiftUI
import SwiftData

struct LocationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [Location]
    @Query private var items: [Item]
    
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @State private var showingAddLocation = false
    @State private var showingLocationDetail = false
    @State private var selectedLocation: Location? = nil
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: Location? = nil
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = true
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索位置...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if filteredLocations.isEmpty {
                    ContentUnavailableView("暂无位置", systemImage: "mappin.slash", description: Text("添加一些位置来开始使用Findr"))
                        .padding(.top, 40)
                } else {
                    List {
                        ForEach(filteredLocations) { location in
                            LocationRow(location: location, itemCount: itemsInLocation(location))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedLocation = location
                                    showingLocationDetail = true
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        locationToDelete = location
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("位置管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddLocation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView()
            }
            .sheet(isPresented: $showingLocationDetail, onDismiss: {
                selectedLocation = nil
            }) {
                if let location = selectedLocation {
                    LocationDetailView(location: location)
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    if let location = locationToDelete {
                        deleteLocation(location)
                    }
                }
            } message: {
                Text("确定要删除位置 \(locationToDelete?.name ?? "")吗？此操作不可撤销。")
            }
            .toast(isShowing: $showingToast, message: toastMessage, isSuccess: toastSuccess)
        }
    }
    
    private var filteredLocations: [Location] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter { location in
                location.name.localizedCaseInsensitiveContains(searchText) ||
                location.sublocationNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    private func itemsInLocation(_ location: Location) -> Int {
        return items.filter { $0.location?.id == location.id }.count
    }
    
    private func deleteLocation(_ location: Location) {
        // 检查是否有物品关联到此位置
        let relatedItems = items.filter { $0.location?.id == location.id }
        
        if relatedItems.isEmpty {
            // 没有关联物品，可以删除
            modelContext.delete(location)
            try? modelContext.save()
            locationToDelete = nil
        } else {
            // 有关联物品，显示提示
            toastMessage = "无法删除位置：该位置下有\(relatedItems.count)个物品"
            toastSuccess = false
            showingToast = true
            locationToDelete = nil
        }
    }
}

struct LocationRow: View {
    let location: Location
    let itemCount: Int
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(location.iconColor))
                    .frame(width: 40, height: 40)
                
                Image(systemName: location.icon)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(location.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(itemCount) 件物品")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                Text("\(location.sublocations.count) 个子位置")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

struct AddLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var icon = "house"
    @State private var iconColor = "red"
    @State private var sublocationText = ""
    @State private var sublocations: [String] = []
    
    let icons = ["house", "bed.double", "sofa", "tv", "refrigerator", "washer", "bathtub", "cabinet", "desk", "table.furniture", "books.vertical", "car", "bicycle", "building.2", "shippingbox", "tray", "archivebox"]
    
    let colors = [
        "red": Color.red,
        "blue": Color.blue,
        "green": Color.green,
        "orange": Color.orange,
        "purple": Color.purple,
        "yellow": Color.yellow,
        "pink": Color.pink,
        "teal": Color.teal
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("位置信息")) {
                    TextField("位置名称", text: $name)
                }
                
                Section(header: Text("图标")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                        ForEach(icons, id: \.self) { iconName in
                            ZStack {
                                Circle()
                                    .fill(Color(iconColor))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: iconName)
                                    .foregroundColor(.white)
                            }
                            .overlay(
                                Circle()
                                    .stroke(iconName == icon ? Color.blue : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                icon = iconName
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                        ForEach(colors.keys.sorted(), id: \.self) { colorKey in
                            Circle()
                                .fill(colors[colorKey]!)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(colorKey == iconColor ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    iconColor = colorKey
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("子位置")) {
                    HStack {
                        TextField("添加子位置", text: $sublocationText)
                        
                        Button(action: addSublocation) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(sublocationText.isEmpty)
                    }
                    
                    ForEach(sublocations, id: \.self) { sublocation in
                        HStack {
                            Text(sublocation)
                            Spacer()
                            Button(action: {
                                if let index = sublocations.firstIndex(of: sublocation) {
                                    sublocations.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
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
                        saveLocation()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func addSublocation() {
        let trimmed = sublocationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !sublocations.contains(trimmed) {
            sublocations.append(trimmed)
            sublocationText = ""
        }
    }
    
    private func saveLocation() {
        // 验证数据
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }
        
        // 创建新位置
        let newLocation = Location(
            name: trimmedName,
            icon: icon,
            iconColor: iconColor,
            sublocationNames: sublocations
        )
        
        // 保存到数据库
        modelContext.insert(newLocation)
        try? modelContext.save()
        
        dismiss()
    }
}

struct LocationDetailView: View {
    let location: Location
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var items: [Item]
    
    @State private var showingDeleteAlert = false
    @State private var showingEditLocation = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = true
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // 位置详情
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(location.iconColor))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: location.icon)
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(itemsInLocation()) 个物品")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingEditLocation = true
                        }) {
                            Image(systemName: "pencil")
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if !location.sublocationNames.isEmpty {
                        Text("子位置")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        ForEach(location.sublocationNames, id: \.self) { sublocation in
                            HStack {
                                Text(sublocation)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("\(itemsInSublocation(sublocation)) 个物品")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                // 位置下的物品列表
                VStack(alignment: .leading) {
                    Text("位置下的物品")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if itemsInLocation() == 0 {
                        ContentUnavailableView("暂无物品", systemImage: "tray", description: Text("该位置下暂无物品"))
                            .padding(.top, 20)
                    } else {
                        List {
                            ForEach(itemsInLocationList()) { item in
                                HStack {
                                    Text(item.name)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text(item.specificLocation)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("位置详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    deleteLocation()
                }
            } message: {
                Text("确定要删除位置 \(location.name) 吗？此操作不可撤销，该位置下的所有物品将失去位置信息。")
            }
            .sheet(isPresented: $showingEditLocation) {
                EditLocationView(location: location)
            }
            .toast(isShowing: $showingToast, message: toastMessage, isSuccess: toastSuccess)
        }
    }
    
    private func itemsInLocation() -> Int {
        return items.filter { $0.location?.id == location.id }.count
    }
    
    private func itemsInLocationList() -> [Item] {
        return items.filter { $0.location?.id == location.id }
    }
    
    private func itemsInSublocation(_ sublocation: String) -> Int {
        return items.filter { $0.location?.id == location.id && $0.specificLocation.contains(sublocation) }.count
    }
    
    private func deleteLocation() {
        // 检查是否有物品关联到此位置
        let relatedItems = items.filter { $0.location?.id == location.id }
        
        if relatedItems.isEmpty {
            // 没有关联物品，可以删除
            modelContext.delete(location)
            try? modelContext.save()
            dismiss()
        } else {
            // 有关联物品，显示提示
            toastMessage = "无法删除位置：该位置下有\(relatedItems.count)个物品"
            toastSuccess = false
            showingToast = true
        }
    }
}

struct EditLocationView: View {
    let location: Location
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var icon: String
    @State private var iconColor: String
    @State private var sublocationText = ""
    @State private var sublocations: [String] = []
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = true
    
    let icons = ["house", "bed.double", "sofa", "tv", "refrigerator", "washer", "bathtub", "cabinet", "desk", "table.furniture", "books.vertical", "car", "bicycle", "building.2", "shippingbox", "tray", "archivebox"]
    
    let colors = [
        "red": Color.red,
        "blue": Color.blue,
        "green": Color.green,
        "orange": Color.orange,
        "purple": Color.purple,
        "yellow": Color.yellow,
        "pink": Color.pink,
        "teal": Color.teal
    ]
    
    init(location: Location) {
        self.location = location
        
        // 初始化状态变量
        _name = State(initialValue: location.name)
        _icon = State(initialValue: location.icon)
        _iconColor = State(initialValue: location.iconColor)
        _sublocations = State(initialValue: location.sublocationNames)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("位置信息")) {
                    TextField("位置名称", text: $name)
                }
                
                Section(header: Text("图标")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                        ForEach(icons, id: \.self) { iconName in
                            ZStack {
                                Circle()
                                    .fill(Color(iconColor))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: iconName)
                                    .foregroundColor(.white)
                            }
                            .overlay(
                                Circle()
                                    .stroke(iconName == icon ? Color.blue : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                icon = iconName
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                        ForEach(colors.keys.sorted(), id: \.self) { colorKey in
                            Circle()
                                .fill(colors[colorKey]!)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(colorKey == iconColor ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    iconColor = colorKey
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("子位置")) {
                    HStack {
                        TextField("添加子位置", text: $sublocationText)
                        Button(action: addSublocation) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(sublocationText.isEmpty)
                    }
                    
                    if !sublocations.isEmpty {
                        ForEach(sublocations, id: \.self) { sublocation in
                            HStack {
                                Text(sublocation)
                                Spacer()
                                Button(action: {
                                    removeSublocation(sublocation)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("编辑位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveLocation()
                    }
                }
            }
            .toast(isShowing: $showingToast, message: toastMessage, isSuccess: toastSuccess)
        }
    }
    
    private func addSublocation() {
        let trimmed = sublocationText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !sublocations.contains(trimmed) {
            sublocations.append(trimmed)
            sublocationText = ""
        }
    }
    
    private func removeSublocation(_ sublocation: String) {
        sublocations.removeAll { $0 == sublocation }
    }
    
    private func saveLocation() {
        // 验证数据
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            toastMessage = "位置名称不能为空"
            toastSuccess = false
            showingToast = true
            return
        }
        
        // 更新位置信息
        location.name = trimmedName
        location.icon = icon
        location.iconColor = iconColor
        
        // 更新子位置 - 先清除现有子位置，然后添加新的子位置
        location.sublocations.removeAll()
        for sublocationName in sublocations {
            location.addSublocation(sublocationName)
        }
        
        // 保存到数据库
        try? modelContext.save()
        
        // 显示Toast提示
        toastMessage = "保存成功"
        toastSuccess = true
        showingToast = true
        
        // 关闭编辑页面
        dismiss()
    }
}

#Preview {
    LocationsView(selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
