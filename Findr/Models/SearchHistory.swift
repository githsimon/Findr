import Foundation

struct SearchHistory: Identifiable {
    let id = UUID()
    let query: String
    let timestamp: Date
}