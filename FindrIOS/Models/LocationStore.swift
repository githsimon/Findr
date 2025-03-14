import Foundation
import SwiftUI

class LocationStore: ObservableObject {
    @Published var locations: [Location] = []
    
    private static func fileURL() -> URL {
        try! FileManager.default.url(for: .documentDirectory, 
                                     in: .userDomainMask, 
                                     appropriateFor: nil, 
                                     create: true)
            .appendingPathComponent("locations.json")
    }
    
    init() {
        loadLocations()
    }
    
    func loadLocations() {
        let fileURL = Self.fileURL()
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                locations = try decoder.decode([Location].self, from: data)
            } catch {
                print("Failed to load locations: \(error)")
                // Initialize with sample data if loading fails
                locations = sampleLocations
            }
        } else {
            // Initialize with sample data for first launch
            locations = sampleLocations
            saveLocations()
        }
    }
    
    func saveLocations() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(locations)
            try data.write(to: Self.fileURL())
        } catch {
            print("Failed to save locations: \(error)")
        }
    }
    
    func addLocation(_ location: Location) {
        locations.append(location)
        saveLocations()
    }
    
    func updateLocation(_ location: Location) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index] = location
            saveLocations()
        }
    }
    
    func deleteLocation(at indexSet: IndexSet) {
        locations.remove(atOffsets: indexSet)
        saveLocations()
    }
    
    func addSublocation(_ sublocation: Sublocation, to locationID: UUID) {
        if let index = locations.firstIndex(where: { $0.id == locationID }) {
            locations[index].sublocations.append(sublocation)
            saveLocations()
        }
    }
    
    // Sample data for testing and first launch
    private var sampleLocations: [Location] = [
        Location(name: "主卧", icon: "bed.double.fill", iconColor: "red", itemCount: 12, 
                sublocations: [
                    Sublocation(name: "衣柜", itemCount: 8),
                    Sublocation(name: "床头柜", itemCount: 4)
                ]),
        Location(name: "厨房", icon: "fork.knife", iconColor: "blue", itemCount: 8,
                sublocations: [
                    Sublocation(name: "上柜", itemCount: 3),
                    Sublocation(name: "下柜", itemCount: 2),
                    Sublocation(name: "抽屉", itemCount: 3)
                ]),
        Location(name: "客厅", icon: "sofa.fill", iconColor: "green", itemCount: 6,
                sublocations: [
                    Sublocation(name: "电视柜", itemCount: 2),
                    Sublocation(name: "茶几", itemCount: 4)
                ]),
        Location(name: "书房", icon: "book.fill", iconColor: "purple", itemCount: 10,
                sublocations: [
                    Sublocation(name: "书桌", itemCount: 5),
                    Sublocation(name: "书架", itemCount: 5)
                ]),
        Location(name: "储物间", icon: "archivebox.fill", iconColor: "yellow", itemCount: 15,
                sublocations: [
                    Sublocation(name: "工具区", itemCount: 8),
                    Sublocation(name: "杂物区", itemCount: 7)
                ])
    ]
}
