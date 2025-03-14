import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("用户信息")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("用户")
                                .font(.headline)
                            Text("findr@example.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("应用设置")) {
                    NavigationLink(destination: Text("通知设置")) {
                        Label("通知", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("外观设置")) {
                        Label("外观", systemImage: "paintbrush")
                    }
                    
                    NavigationLink(destination: Text("隐私设置")) {
                        Label("隐私", systemImage: "lock.shield")
                    }
                }
                
                Section(header: Text("数据管理")) {
                    Button(action: {
                        itemStore.saveItemsToFile()
                        locationStore.saveLocationsToFile()
                    }) {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        itemStore.loadItemsFromFile()
                        locationStore.loadLocationsFromFile()
                    }) {
                        Label("导入数据", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        Label("清除所有数据", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingConfirmation) {
                        Alert(
                            title: Text("确认清除"),
                            message: Text("此操作将清除所有物品和位置数据，且无法恢复。确定要继续吗？"),
                            primaryButton: .destructive(Text("清除")) {
                                itemStore.items = []
                                locationStore.locations = []
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink(destination: Text("帮助与反馈")) {
                        Label("帮助与反馈", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: Text("关于Findr")) {
                        Label("关于Findr", systemImage: "info.circle")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ItemStore())
        .environmentObject(LocationStore())
}
