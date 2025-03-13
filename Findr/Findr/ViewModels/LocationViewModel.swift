import SwiftUI

struct LocationGroup: Identifiable {
    let id = UUID()
    let name: String
    let locations: [Location]
}

class LocationViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var groupedLocations: [LocationGroup] = []
    
    init() {
        // 临时测试数据
        locations = [
            Location(id: "living_room", name: "客厅", type: .room, description: "家庭活动区域"),
            Location(id: "kitchen", name: "厨房", type: .room, description: "烹饪区域"),
            Location(id: "kitchen_cabinet", name: "厨房橱柜", type: .cabinet, parentId: "kitchen", description: "厨房的储物柜"),
            Location(id: "bedroom", name: "主卧", type: .room, description: "主卧室"),
            Location(id: "wardrobe", name: "衣柜", type: .cabinet, parentId: "bedroom", description: "主卧的衣柜")
        ]
        updateGroupedLocations()
    }
    
    func updateGroupedLocations() {
        let rooms = locations.filter { $0.type == .room }
        var groups: [LocationGroup] = []
        
        for room in rooms {
            let children = locations.filter { $0.parentId == room.id }
            groups.append(LocationGroup(name: room.name, locations: [room] + children))
        }
        
        groupedLocations = groups
    }
    
    func addLocation(_ location: Location) {
        locations.append(location)
        updateGroupedLocations()
        // TODO: 保存到本地存储
    }
    
    func deleteLocation(_ location: Location) {
        locations.removeAll { $0.id == location.id }
        // 同时删除子位置
        locations.removeAll { $0.parentId == location.id }
        updateGroupedLocations()
        // TODO: 从本地存储中删除
    }
    
    func updateLocation(_ locationId: String, name: String, type: LocationType) {
        if let index = locations.firstIndex(where: { $0.id == locationId }) {
            var updatedLocation = locations[index]
            updatedLocation.name = name
            updatedLocation.type = type
            locations[index] = updatedLocation
            updateGroupedLocations()
            // TODO: 更新本地存储
        }
    }
    
    func getParentLocationName(for location: Location) -> String? {
        guard let parentId = location.parentId else { return nil }
        return locations.first { $0.id == parentId }?.name
    }
    
    func getRoomLocations() -> [Location] {
        return locations.filter { $0.type == .room }
    }
}
