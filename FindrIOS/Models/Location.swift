import Foundation
import SwiftUI

struct Location: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var icon: String
    var iconColor: String
    var itemCount: Int = 0
    var sublocations: [Sublocation] = []
    
    var colorValue: Color {
        switch iconColor {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "yellow": return .yellow
        case "orange": return .orange
        case "gray": return .gray
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .blue
        }
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

struct Sublocation: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var itemCount: Int = 0
    
    static func == (lhs: Sublocation, rhs: Sublocation) -> Bool {
        lhs.id == rhs.id
    }
}
