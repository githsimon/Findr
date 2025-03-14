import Foundation
import SwiftUI

class LocationStore: ObservableObject {
    @Published var locations: [Location] = [] {
        didSet {
            saveLocations()
        }
    }
    
    private let locationsKey = "savedLocations"
    
    init() {
        loadLocations()
    }
    
    func addLocation(_ location: Location) {
        locations.append(location)
    }
    
    func deleteLocation(at indexSet: IndexSet) {
        locations.remove(atOffsets: indexSet)
    }
    
    func deleteLocation(withId id: UUID) {
        if let index = locations.firstIndex(where: { $0.id == id }) {
            locations.remove(at: index)
        }
    }
    
    func updateLocation(_ location: Location) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index] = location
        }
    }
    
    func getLocationById(_ id: UUID) -> Location? {
        return locations.first(where: { $0.id == id })
    }
    
    func addSublocation(to locationId: UUID, sublocation: Sublocation) {
        if let index = locations.firstIndex(where: { $0.id == locationId }) {
            locations[index].sublocations.append(sublocation)
        }
    }
    
    func removeSublocation(from locationId: UUID, sublocationId: UUID) {
        if let locationIndex = locations.firstIndex(where: { $0.id == locationId }),
           let sublocationIndex = locations[locationIndex].sublocations.firstIndex(where: { $0.id == sublocationId }) {
            locations[locationIndex].sublocations.remove(at: sublocationIndex)
        }
    }
    
    private func saveLocations() {
        if let encodedData = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encodedData, forKey: locationsKey)
        }
    }
    
    private func loadLocations() {
        guard let data = UserDefaults.standard.data(forKey: locationsKey) else { 
            // Load sample data if no saved data exists
            loadSampleData()
            return 
        }
        
        if let decodedLocations = try? JSONDecoder().decode([Location].self, from: data) {
            locations = decodedLocations
        }
    }
    
    private func loadSampleData() {
        // Create sample data for preview and first launch
        let sampleLocations: [Location] = [
            Location(
                name: "主卧",
                icon: .bedroom,
                sublocations: [
                    Sublocation(name: "衣柜"),
                    Sublocation(name: "床头柜")
                ]
            ),
            Location(
                name: "厨房",
                icon: .kitchen,
                sublocations: [
                    Sublocation(name: "上柜"),
                    Sublocation(name: "下柜"),
                    Sublocation(name: "抽屉"),
                    Sublocation(name: "冰箱"),
                    Sublocation(name: "调料架")
                ]
            ),
            Location(
                name: "客厅",
                icon: .livingRoom,
                sublocations: [
                    Sublocation(name: "电视柜"),
                    Sublocation(name: "茶几"),
                    Sublocation(name: "书架")
                ]
            ),
            Location(
                name: "书房",
                icon: .study,
                sublocations: [
                    Sublocation(name: "书桌"),
                    Sublocation(name: "书柜")
                ]
            ),
            Location(
                name: "储物间",
                icon: .storage,
                sublocations: [
                    Sublocation(name: "上层架子"),
                    Sublocation(name: "中层架子"),
                    Sublocation(name: "下层架子"),
                    Sublocation(name: "工具箱")
                ]
            )
        ]
        
        locations = sampleLocations
    }
    
    // Save locations to a JSON file in the Documents directory
    func saveLocationsToFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(locations)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("locations.json")
            try data.write(to: fileURL)
            print("Locations saved to: \(fileURL.path)")
        } catch {
            print("Error saving locations to file: \(error)")
        }
    }
    
    // Load locations from a JSON file in the Documents directory
    func loadLocationsFromFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("locations.json")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                locations = try decoder.decode([Location].self, from: data)
                print("Locations loaded from: \(fileURL.path)")
            } catch {
                print("Error loading locations from file: \(error)")
            }
        }
    }
}
