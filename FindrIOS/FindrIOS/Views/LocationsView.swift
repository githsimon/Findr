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
    
    @State private var searchText = ""
    @State private var showingAddLocation = false
    @State private var selectedLocation: Location?
    @State private var showingLocationDetail = false
    
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
                
                if locations.isEmpty {
                    ContentUnavailableView("暂无位置", systemImage: "mappin.slash", description: Text("添加一些位置来开始整理物品"))
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
                        }
                        .onDelete(perform: deleteLocations)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("位置管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("添加位置", action: { showingAddLocation = true })
                        Button("编辑", action: {})
                    } label: {
                        Image(systemName: "ellipsis")
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
        }
    }
    
    private var filteredLocations: [Location] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func itemsInLocation(_ location: Location) -> Int {
        return items.filter { $0.location?.id == location.id }.count
    }
    
    private func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            let location = locations[index]
            modelContext.delete(location)
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
        let newLocation = Location(
            name: name,
            icon: icon,
            iconColor: iconColor,
            sublocations: sublocations
        )
        
        modelContext.insert(newLocation)
        dismiss()
    }
}

struct LocationDetailView: View {
    let location: Location
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingEditLocation = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // 位置详情
                VStack(alignment: .leading, spacing: 16) {
                    Text("子位置")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if location.sublocations.isEmpty {
                        Text("暂无子位置")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(location.sublocations, id: \.self) { sublocation in
                            HStack {
                                Text(sublocation)
                                Spacer()
                                Text("\(itemsInSublocation(sublocation)) 件物品")
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
                
                Divider()
                
                // 最近添加的物品
                VStack(alignment: .leading, spacing: 16) {
                    Text("最近添加的物品")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    let locationItems = items.filter { $0.location?.id == location.id }
                    
                    if locationItems.isEmpty {
                        Text("暂无物品")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(locationItems.sorted(by: { $0.timestamp > $1.timestamp }).prefix(3)) { item in
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(8)
                                } else {
                                    Image(systemName: "photo")
                                        .frame(width: 40, height: 40)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("\(item.specificLocation)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("编辑") {
                        showingEditLocation = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showingEditLocation) {
                EditLocationView(location: location)
            }
        }
    }
    
    private func itemsInSublocation(_ sublocation: String) -> Int {
        return items.filter { $0.location?.id == location.id && $0.specificLocation.contains(sublocation) }.count
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
    @State private var sublocations: [String]
    
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
        _name = State(initialValue: location.name)
        _icon = State(initialValue: location.icon)
        _iconColor = State(initialValue: location.iconColor)
        _sublocations = State(initialValue: location.sublocations)
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
                        updateLocation()
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
    
    private func updateLocation() {
        location.name = name
        location.icon = icon
        location.iconColor = iconColor
        location.sublocations = sublocations
        
        dismiss()
    }
}

#Preview {
    LocationsView()
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
