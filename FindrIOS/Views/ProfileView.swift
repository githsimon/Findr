import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var locationStore: LocationStore
    @State private var showingSettingsView = false
    @State private var showingEditProfileView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack {
                        HStack {
                            Image("profile_avatar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(.systemGray6), lineWidth: 3))
                                .shadow(radius: 3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("李小花")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("lixiaohua@example.com")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    showingEditProfileView = true
                                }) {
                                    HStack {
                                        Text("编辑个人资料")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.leading, 12)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Statistics
                    HStack(spacing: 12) {
                        StatBox(title: "总物品", value: "\(itemStore.items.count)")
                        StatBox(title: "位置", value: "\(locationStore.locations.count)")
                        StatBox(title: "分类", value: "\(Category.allCases.count)")
                    }
                    .padding(.horizontal)
                    
                    // Menu Section 1
                    MenuSection(items: [
                        MenuItem(icon: "clock.arrow.circlepath", iconColor: .purple, title: "最近活动"),
                        MenuItem(icon: "star.fill", iconColor: .green, title: "收藏物品"),
                        MenuItem(icon: "bell.fill", iconColor: .blue, title: "提醒", badge: "2")
                    ])
                    .padding(.horizontal)
                    
                    // Menu Section 2
                    MenuSection(items: [
                        MenuItem(icon: "tag.fill", iconColor: .yellow, title: "标签管理"),
                        MenuItem(icon: "paintpalette.fill", iconColor: .red, title: "外观设置")
                    ])
                    .padding(.horizontal)
                    
                    // Account Settings
                    MenuSection(items: [
                        MenuItem(icon: "person.circle.fill", iconColor: .gray, title: "账号信息"),
                        MenuItem(icon: "lock.fill", iconColor: .indigo, title: "隐私设置"),
                        MenuItem(icon: "questionmark.circle.fill", iconColor: .teal, title: "帮助与反馈"),
                        MenuItem(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: "退出登录", textColor: .red)
                    ])
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("个人中心")
            .navigationBarItems(trailing: Button(action: {
                showingSettingsView = true
            }) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.blue)
            })
            .sheet(isPresented: $showingSettingsView) {
                SettingsView()
            }
            .sheet(isPresented: $showingEditProfileView) {
                EditProfileView()
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let badge: String?
    let textColor: Color
    
    init(icon: String, iconColor: Color, title: String, badge: String? = nil, textColor: Color = .primary) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.badge = badge
        self.textColor = textColor
    }
}

struct MenuSection: View {
    let items: [MenuItem]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                MenuItemRow(item: item)
                
                if item.id != items.last?.id {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item.iconColor)
                    .frame(width: 32, height: 32)
                
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            Text(item.title)
                .foregroundColor(item.textColor)
                .padding(.leading, 12)
            
            Spacer()
            
            if let badge = item.badge {
                Text(badge)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.trailing, 4)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("设置页面")
                .navigationTitle("设置")
                .navigationBarItems(trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = "李小花"
    @State private var email = "lixiaohua@example.com"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("个人信息")) {
                    HStack {
                        Spacer()
                        
                        Image("profile_avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.systemGray6), lineWidth: 3))
                            .shadow(radius: 3)
                            .overlay(
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    )
                                    .shadow(radius: 2)
                                    .offset(x: 5, y: 5),
                                alignment: .bottomTrailing
                            )
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    TextField("姓名", text: $name)
                    TextField("邮箱", text: $email)
                }
            }
            .navigationTitle("编辑个人资料")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    // Save profile changes
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ItemStore())
            .environmentObject(LocationStore())
    }
}
