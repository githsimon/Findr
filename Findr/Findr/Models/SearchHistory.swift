import Foundation

struct SearchHistory: Identifiable, Codable {
    let id = UUID()
    let keyword: String
    let filter: SearchFilter
    let date: Date
}

enum SearchFilter: String, CaseIterable, Codable {
    case all = "全部"
    case name = "名称"
    case location = "位置"
    case tags = "标签"
}