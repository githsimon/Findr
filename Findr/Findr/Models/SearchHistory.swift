import Foundation

struct SearchHistory: Identifiable, Codable {
    let id = UUID()
    let keyword: String
    let filter: SearchFilter
    let date: Date
    
    init(keyword: String, filter: SearchFilter, date: Date = Date()) {
        self.keyword = keyword
        self.filter = filter
        self.date = date
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}