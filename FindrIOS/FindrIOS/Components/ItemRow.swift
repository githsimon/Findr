//
//  ItemRow.swift
//  FindrIOS
//
//  Created on 2025/3/15.
//

import SwiftUI

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 15) {
            // 物品图片
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // 使用分类图标作为默认图片
                let category = ItemCategory.allCases.first(where: { $0.rawValue == item.category }) ?? .other
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(category.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(category.color)
                }
            }
            
            // 物品信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                // 位置信息
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let location = item.location {
                        Text("\(location.name) · \(item.specificLocation)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    } else {
                        Text(item.specificLocation)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                // 标签
                if !item.tagNames.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(item.tagNames.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                            
                            if item.tagNames.count > 3 {
                                Text("+\(item.tagNames.count - 3)")
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .foregroundColor(.gray)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 20)
                }
            }
            
            Spacer()
            
            // 时间信息
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDate(item.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ItemRow(item: Item(name: "测试物品", category: "衣物", specificLocation: "衣柜"))
        .padding()
        .previewLayout(.sizeThatFits)
}
