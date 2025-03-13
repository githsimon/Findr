import Foundation

struct Location: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var type: LocationType
    var parentId: String?
    var description: String
    
    init(id: String = UUID().uuidString,
         name: String,
         type: LocationType,
         parentId: String? = nil,
         description: String) {
        self.id = id
        self.name = name
        self.type = type
        self.parentId = parentId
        self.description = description
    }
}

enum LocationType: String, Codable, CaseIterable {
    case room = "room"
    case cabinet = "cabinet"
    case drawer = "drawer"
    case shelf = "shelf"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .room: return "房间"
        case .cabinet: return "柜子"
        case .drawer: return "抽屉"
        case .shelf: return "架子"
        case .other: return "其他"
        }
    }
}
