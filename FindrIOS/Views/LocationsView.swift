import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var locationStore: LocationStore
    @EnvironmentObject var itemStore: ItemStore
    @State private var searchText = ""
    @State private var showingAddLocation = false
    @State private var selectedLocation: Location? = nil
    
    var filteredLocations: [Location] {
        if searchText.isEmpty {
            return locationStore.locations
        } else {
            return locationStore.locations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索位置...", text: $searchText)
                        .font(.system(size: 17))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Locations List
                List {
                    ForEach(filteredLocations) { location in
                        LocationRow(location: location, itemStore: itemStore)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                    .onDelete { indexSet in
                        locationStore.deleteLocation(at: indexSet)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("位置管理")
            .navigationBarItems(trailing:
                Menu {
                    Button(action: {
                        showingAddLocation = true
                    }) {
                        Label("添加位置", systemImage: "plus")
                    }
                    
                    Button(action: {
                        // Sort action
                    }) {
                        Label("排序", systemImage: "arrow.up.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                }
            )
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView()
            }
            .sheet(item: $selectedLocation) { location in
                LocationDetailView(location: location)
            }
            .overlay(
                VStack {
                    Spacer()
                    
                    Button(action: {
                        showingAddLocation = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 16)
                }
            )
        }
    }
}

struct LocationRow: View {
    let location: Location
    let itemStore: ItemStore
    
    var itemCount: Int {
        itemStore.getItemsByLocation(locationId: location.id).count
    }
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(location.icon.color)
                    .frame(width: 40, height: 40)
                
                Image(systemName: location.icon.rawValue)
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
                        .background(Color(.systemGray5))
                        .cornerRadius(16)
                }
                
                Text("\(location.sublocations.count) 个子位置")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct LocationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    let location: Location
    @State private var showingAddSublocation = false
    @State private var newSublocationName = ""
    @State private var showingEditMode = false
    
    var locationItems: [Item] {
        itemStore.getItemsByLocation(locationId: location.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Sublocations Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("子位置")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddSublocation = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if location.sublocations.isEmpty {
                            Text("暂无子位置")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(location.sublocations) { sublocation in
                                HStack {
                                    Text(sublocation.name)
                                    
                                    Spacer()
                                    
                                    let sublocationItems = locationItems.filter { $0.specificLocation == sublocation.name }
                                    Text("\(sublocationItems.count) 件物品")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    if showingEditMode {
                                        Button(action: {
                                            locationStore.removeSublocation(from: location.id, sublocationId: sublocation.id)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Recent Items Section
                    VStack(alignment: .leading) {
                        Text("最近添加的物品")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        if locationItems.isEmpty {
                            Text("暂无物品")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(locationItems.prefix(3)) { item in
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(item.category.color.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: item.category.icon)
                                            .foregroundColor(item.category.color)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(item.specificLocation)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 8)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(location.name)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("关闭")
                },
                trailing: Button(action: {
                    showingEditMode.toggle()
                }) {
                    Text(showingEditMode ? "完成" : "编辑")
                }
            )
            .alert(isPresented: $showingAddSublocation) {
                Alert(
                    title: Text("添加子位置"),
                    message: Text("请输入子位置名称"),
                    TextField("名称", text: $newSublocationName),
                    primaryButton: .default(Text("添加")) {
                        if !newSublocationName.isEmpty {
                            let newSublocation = Sublocation(name: newSublocationName)
                            locationStore.addSublocation(to: location.id, sublocation: newSublocation)
                            newSublocationName = ""
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct AddLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var locationStore: LocationStore
    @State private var locationName = ""
    @State private var selectedIcon: Location.LocationIcon = .bedroom
    @State private var sublocations: [String] = [""]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("位置信息")) {
                    TextField("位置名称", text: $locationName)
                    
                    Picker("图标", selection: $selectedIcon) {
                        ForEach(Location.LocationIcon.allCases, id: \.self) { icon in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(icon.color)
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: icon.rawValue)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                }
                                
                                Text(icon.displayName)
                            }
                            .tag(icon)
                        }
                    }
                }
                
                Section(header: Text("子位置")) {
                    ForEach(0..<sublocations.count, id: \.self) { index in
                        HStack {
                            TextField("子位置名称", text: $sublocations[index])
                            
                            if sublocations.count > 1 {
                                Button(action: {
                                    sublocations.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        sublocations.append("")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加子位置")
                        }
                    }
                }
            }
            .navigationTitle("添加位置")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("取消")
                },
                trailing: Button(action: {
                    saveLocation()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("保存")
                }
                .disabled(locationName.isEmpty)
            )
        }
    }
    
    private func saveLocation() {
        let filteredSublocations = sublocations
            .filter { !$0.isEmpty }
            .map { Sublocation(name: $0) }
        
        let newLocation = Location(
            name: locationName,
            icon: selectedIcon,
            sublocations: filteredSublocations
        )
        
        locationStore.addLocation(newLocation)
    }
}

#Preview {
    LocationsView()
        .environmentObject(LocationStore())
        .environmentObject(ItemStore())
}
