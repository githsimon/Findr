import SwiftUI

@main
struct FindrApp: App {
    @StateObject private var locationStore = LocationStore()
    @StateObject private var itemStore = ItemStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationStore)
                .environmentObject(itemStore)
        }
    }
}
