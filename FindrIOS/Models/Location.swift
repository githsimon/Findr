import Foundation
import SwiftUI

struct Location: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: LocationIcon
    var sublocations: [Sublocation]
    
    enum LocationIcon: String, Codable, CaseIterable {
        case bedroom = "bed.double"
        case kitchen = "fork.knife"
        case livingRoom = "sofa"
        case study = "book"
        case storage = "archivebox"
        case bathroom = "shower"
        case garage = "car"
        case other = "square.grid.2x2"
        
        var color: Color {
            switch self {
            case .bedroom: return .red
            case .kitchen: return .blue
            case .livingRoom: return .green
            case .study: return .purple
            case .storage: return .yellow
            case .bathroom: return .cyan
            case .garage: return .orange
            case .other: return .gray
            }
        }
        
        var displayName: String {
            switch self {
            case .bedroom: return "卧室"
            case .kitchen: return "厨房"
            case .livingRoom: return "客厅"
            case .study: return "书房"
            case .storage: return "储物间"
            case .bathroom: return "浴室"
            case .garage: return "车库"
            case .other: return "其他"
            }
        }
    }
}

struct Sublocation: Identifiable, Codable {
    var id = UUID()
    var name: String
}
