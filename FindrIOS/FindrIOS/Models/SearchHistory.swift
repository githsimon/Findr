//
//  SearchHistory.swift
//  FindrIOS
//
//  Created on 2025/3/14.
//

import Foundation

// 搜索过滤器枚举
enum SearchFilter: String, Codable, CaseIterable {
    case all = "全部"
    case clothing = "衣物"
    case kitchen = "厨房"
    case books = "书籍"
    case tools = "工具"
    case electronics = "电子"
    case stationery = "文具"
    case decoration = "装饰"
    case other = "其他"
}

// 搜索历史记录模型
struct SearchHistory: Identifiable, Codable {
    var id = UUID()
    var query: String
    var filter: SearchFilter
    var timestamp: Date
    
    // 格式化的日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    init(query: String, filter: SearchFilter = .all, timestamp: Date = Date()) {
        self.query = query
        self.filter = filter
        self.timestamp = timestamp
    }
}
