import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house")
                }
                .tag(0)
            
            AddItemView()
                .tabItem {
                    Label("添加", systemImage: "plus.circle")
                }
                .tag(1)
            
            LocationsView()
                .tabItem {
                    Label("位置", systemImage: "mappin.and.ellipse")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ItemStore())
        .environmentObject(LocationStore())
}
