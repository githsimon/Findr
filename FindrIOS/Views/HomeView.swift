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
                            
                            Button(action: {
                                // View all categories action
                            }) {
                                Text("查看全部")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Item.Category.allCases, id: \.self) { category in
                                    CategoryButton(category: category)
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
                        
                        ForEach(itemStore.getRecentItems()) { item in
                            ItemCard(item: item)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Statistics
                    VStack(alignment: .leading) {
                        Text("统计")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            StatisticCard(
                                icon: "cube",
                                iconColor: .blue,
                                title: "总物品",
                                value: "\(itemStore.items.count)"
                            )
                            
                            StatisticCard(
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
            .navigationBarItems(trailing:
                Button(action: {
                    // Filter action
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.blue)
                }
            )
        }
    }
}

struct CategoryButton: View {
    let category: Item.Category
    
    var body: some View {
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
                .foregroundColor(.primary)
        }
    }
}

struct ItemCard: View {
    let item: Item
    @EnvironmentObject var locationStore: LocationStore
    
    var locationName: String {
        if let location = locationStore.getLocationById(item.locationId) {
            return "\(location.name) - \(item.specificLocation)"
        }
        return item.specificLocation
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(item.category.color.opacity(0.2))
                    .foregroundColor(item.category.color)
                    .cornerRadius(16)
            }
            
            Spacer()
            
            // Placeholder for item image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                
                if let imageName = item.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(item.category.color)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatisticCard: View {
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
        .environmentObject(ItemStore())
        .environmentObject(LocationStore())
}
