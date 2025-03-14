//
//  ContentView.swift
//  FindrIOS
//
//  Created by 杨颂 on 2025/3/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
