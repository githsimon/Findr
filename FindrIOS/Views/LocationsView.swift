import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var locationStore: LocationStore
    @State private var searchText = ""
    @State private var showingAddLocation = false
    @State private var selectedLocation: Location?
    
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
                
                List {
                    ForEach(filteredLocations) { location in
                        Button(action: {
                            selectedLocation = location
                        }) {
                            LocationRowView(location: location)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteLocation)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("位置管理")
            .navigationBarItems(trailing: Button(action: {
                showingAddLocation = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.blue)
            })
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView()
            }
            .sheet(item: $selectedLocation) { location in
                LocationDetailView(location: location)
            }
        }
    }
    
    func deleteLocation(at offsets: IndexSet) {
        locationStore.deleteLocation(at: offsets)
    }
}

struct LocationRowView: View {
    let location: Location
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(location.colorValue)
                    .frame(width: 40, height: 40)
                
                Image(systemName: location.icon)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(location.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(location.itemCount) 件物品")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Text("\(location.sublocations.count) 个子位置")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct LocationDetailView: View {
    @EnvironmentObject var locationStore: LocationStore
    @EnvironmentObject var itemStore: ItemStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddSublocation = false
    @State private var location: Location
    
    init(location: Location) {
        _location = State(initialValue: location)
    }
    
    var locationItems: [Item] {
        itemStore.getItemsByLocation(locationID: location.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
                                Label("添加", systemImage: "plus")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if location.sublocations.isEmpty {
                            Text("暂无子位置")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        } else {
                            ForEach(location.sublocations) { sublocation in
                                HStack {
                                    Text(sublocation.name)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text("\(sublocation.itemCount) 件物品")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
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
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        } else {
                            ForEach(locationItems.prefix(3)) { item in
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(item.category.color.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: item.category.icon)
                                            .foregroundColor(item.category.color)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        if let sublocation = item.sublocationName {
                                            Text(sublocation + (item.specificLocation != nil ? " - \(item.specificLocation!)" : ""))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.leading, 8)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(location.name)
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("编辑") {
                    // Edit location action
                }
            )
            .sheet(isPresented: $showingAddSublocation) {
                AddSublocationView(location: $location)
            }
        }
    }
}

struct AddLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var locationStore: LocationStore
    
    @State private var name = ""
    @State private var selectedIcon = "house.fill"
    @State private var selectedColor = "blue"
    
    let icons = [
        "house.fill", "bed.double.fill", "sofa.fill", "fork.knife", 
        "book.fill", "archivebox.fill", "car.fill", "briefcase.fill",
        "desktopcomputer", "gamecontroller.fill", "tray.fill", "leaf.fill"
    ]
    
    let colors = [
        "red", "blue", "green", "purple", "yellow", 
        "orange", "gray", "indigo", "teal"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("位置信息")) {
                    TextField("位置名称", text: $name)
                }
                
                Section(header: Text("图标")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(selectedIcon == icon ? 0.2 : 0))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                            .onTapGesture {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(colorFromString(color))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: selectedColor == color ? 2 : 0)
                                        .padding(-4)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("添加位置")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveLocation()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "yellow": return .yellow
        case "orange": return .orange
        case "gray": return .gray
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .blue
        }
    }
    
    func saveLocation() {
        let newLocation = Location(
            name: name,
            icon: selectedIcon,
            iconColor: selectedColor
        )
        
        locationStore.addLocation(newLocation)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddSublocationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var locationStore: LocationStore
    @Binding var location: Location
    
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("子位置信息")) {
                    TextField("子位置名称", text: $name)
                }
            }
            .navigationTitle("添加子位置")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveSublocation()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    func saveSublocation() {
        let newSublocation = Sublocation(name: name)
        
        // Update local state
        location.sublocations.append(newSublocation)
        
        // Update in store
        locationStore.updateLocation(location)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationStore())
            .environmentObject(ItemStore())
    }
}
