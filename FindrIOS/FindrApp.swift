import SwiftUI

@main
struct FindrApp: App {
    @StateObject private var itemStore = ItemStore()
    @StateObject private var locationStore = LocationStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(itemStore)
                .environmentObject(locationStore)
        }
    }
}
