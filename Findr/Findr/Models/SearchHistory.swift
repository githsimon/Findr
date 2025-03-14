import Foundation

struct SearchHistory: Identifiable, Codable {
    let id: UUID
    let keyword: String
    let filter: SearchFilter
    let date: Date
    
    init(id: UUID = UUID(), keyword: String, filter: SearchFilter, date: Date = Date()) {
        self.id = id
        self.keyword = keyword
        self.filter = filter
        self.date = date
    }
    
    // 添加编码和解码方法
    enum CodingKeys: String, CodingKey {
        case id, keyword, filter, date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        keyword = try container.decode(String.self, forKey: .keyword)
        filter = try container.decode(SearchFilter.self, forKey: .filter)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(keyword, forKey: .keyword)
        try container.encode(filter, forKey: .filter)
        try container.encode(date, forKey: .date)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}