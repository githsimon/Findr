//
//  FindrIOSApp.swift
//  FindrIOS
//
//  Created by 杨颂 on 2025/3/14.
//

import SwiftUI
import SwiftData

@main
struct FindrIOSApp: App {
    init() {
        // 注册安全转换器
        TransformerRegistration.register()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Location.self,
            ItemTag.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
