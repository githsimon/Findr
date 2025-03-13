import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var itemListViewModel = ItemListViewModel()
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                ItemListView()
                    .environmentObject(itemListViewModel)
            }
            .tabItem {
                Label("物品", systemImage: "list.bullet")
            }
            
            NavigationView {
                LocationView()
                    .environmentObject(locationViewModel)
            }
            .tabItem {
                Label("位置", systemImage: "house")
            }
            
            NavigationView {
                SearchView()
                    .environmentObject(searchViewModel)
            }
            .tabItem {
                Label("搜索", systemImage: "magnifyingglass")
            }
        }
    }
}

#Preview {
    ContentView()
}
