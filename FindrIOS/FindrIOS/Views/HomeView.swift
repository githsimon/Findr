//
//  HomeView.swift
//  FindrIOS
//
//  Created on 2025/3/14.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var locations: [Location]
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 搜索栏
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("搜索物品...", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // 快速查找分类
                    VStack(alignment: .leading) {
                        HStack {
                            Text("快速查找")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button("查看全部") {
                                // 查看全部分类的操作
                            }
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(ItemCategory.allCases, id: \.self) { category in
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(category.color.opacity(0.2))
                                                .frame(width: 64, height: 64)
                                            
                                            Image(systemName: category.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(category.color)
                                        }
                                        Text(category.rawValue)
                                            .font(.caption)
                                    }
                                    .onTapGesture {
                                        // 点击分类的操作
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // 最近添加的物品
                    VStack(alignment: .leading) {
                        Text("最近添加")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if items.isEmpty {
                            ContentUnavailableView("暂无物品", systemImage: "tray", description: Text("添加一些物品来开始使用Findr"))
                                .padding(.top, 20)
                        } else {
                            ForEach(items.sorted(by: { $0.timestamp > $1.timestamp }).prefix(3)) { item in
                                ItemCardView(item: item)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // 统计信息
                    VStack(alignment: .leading) {
                        Text("统计")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            StatisticCardView(
                                icon: "cube",
                                iconColor: .blue,
                                title: "总物品",
                                value: "\(items.count)"
                            )
                            
                            StatisticCardView(
                                icon: "mappin.and.ellipse",
                                iconColor: .green,
                                title: "存放位置",
                                value: "\(locations.count)"
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Findr")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // 打开过滤器
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
    }
}

struct ItemCardView: View {
    let item: Item
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                
                if let location = item.location {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                        Text("\(location.name) - \(item.specificLocation)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(item.category)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(16)
            }
            
            Spacer()
            
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatisticCardView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
