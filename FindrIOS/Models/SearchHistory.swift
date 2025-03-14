import Foundation

struct SearchHistory: Identifiable, Codable, Equatable {
    var id = UUID()
    var query: String
    var date: Date = Date()
    
    static func == (lhs: SearchHistory, rhs: SearchHistory) -> Bool {
        lhs.id == rhs.id
    }
}
