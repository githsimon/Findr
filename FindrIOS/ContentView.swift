import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0)
            
            LocationsView()
                .tabItem {
                    Label("位置", systemImage: "mappin.and.ellipse")
                }
                .tag(1)
            
            Text("添加")
                .tabItem {
                    Label("添加", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            Text("搜索")
                .tabItem {
                    Label("搜索", systemImage: "magnifyingglass")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}
