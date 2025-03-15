//
//  MainTabView.swift
//  FindrIOS
//
//  Created on 2025/3/14.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("首页", systemImage: "house")
                }
                .tag(0)
            
            LocationsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("位置", systemImage: "mappin.and.ellipse")
                }
                .tag(1)
            
            AddItemView(selectedTab: $selectedTab)
                .tabItem {
                    Label("添加", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            SearchView(selectedTab: $selectedTab)
                .tabItem {
                    Label("搜索", systemImage: "magnifyingglass")
                }
                .tag(3)
            
            ProfileView(selectedTab: $selectedTab)
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Item.self, Location.self, Tag.self], inMemory: true)
}
