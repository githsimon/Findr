import SwiftUI

struct HomeView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("搜索物品...", text: $searchText)
                            .font(.system(size: 17))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Quick Categories
                    VStack(alignment: .leading) {
                        HStack {
                            Text("快速查找")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            NavigationLink(destination: Text("所有分类")) {
                                Text("查看全部")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Category.allCases) { category in
                                    VStack {
                                        Circle()
                                            .fill(category.color.opacity(0.2))
                                            .frame(width: 64, height: 64)
                                            .overlay(
                                                Image(systemName: category.icon)
                                                    .font(.system(size: 24))
                                                    .foregroundColor(category.color)
                                            )
                                        
                                        Text(category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Items
                    VStack(alignment: .leading) {
                        Text("最近添加")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(itemStore.getRecentItems()) { item in
                                ItemCardView(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Statistics
                    VStack(alignment: .leading) {
                        Text("统计")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            StatCardView(
                                icon: "cube.box.fill",
                                iconColor: .blue,
                                title: "总物品",
                                value: "\(itemStore.items.count)"
                            )
                            
                            StatCardView(
                                icon: "mappin.and.ellipse",
                                iconColor: .green,
                                title: "存放位置",
                                value: "\(locationStore.locations.count)"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Findr")
            .navigationBarItems(trailing: Button(action: {
                // Filter action
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
            })
        }
    }
}

struct ItemCardView: View {
    let item: Item
    @EnvironmentObject var locationStore: LocationStore
    
    var locationName: String {
        if let location = locationStore.locations.first(where: { $0.id == item.locationID }) {
            if let sublocation = item.sublocationName {
                if let specific = item.specificLocation {
                    return "\(location.name) - \(sublocation) - \(specific)"
                }
                return "\(location.name) - \(sublocation)"
            }
            return location.name
        }
        return "未知位置"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(locationName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.category.color.opacity(0.2))
                    .foregroundColor(item.category.color)
                    .cornerRadius(10)
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 64, height: 64)
                
                if item.imageFileName != nil {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(item.category.color)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatCardView: View {
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
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ItemStore())
            .environmentObject(LocationStore())
    }
}
