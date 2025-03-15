//
//  ProfileView.swift
//  FindrIOS
//
//  Created on 2025/3/14.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var locations: [Location]
    
    @Binding var selectedTab: Int
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    // 用户信息（实际应用中应该从用户系统获取）
    @State private var userName = "大宝贝"
    @State private var userEmail = "dabaobei@example.com"
    @State private var userAvatar: UIImage? = nil
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户头像和信息
                    HStack {
                        if let avatar = userAvatar {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(.systemGray6), lineWidth: 3))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(userEmail)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showingEditProfile = true
                            }) {
                                HStack {
                                    Text("编辑个人资料")
                                        .font(.subheadline)
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
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // 统计信息
                    HStack(spacing: 12) {
                        StatCard(title: "总物品", value: "\(items.count)")
                        StatCard(title: "位置", value: "\(locations.count)")
                        StatCard(title: "分类", value: "\(uniqueCategories.count)")
                    }
                    
                    // 功能菜单 - 第一组
                    MenuSection {
                        MenuRow(icon: "clock", iconColor: .purple, title: "最近活动")
                        MenuRow(icon: "star", iconColor: .green, title: "收藏物品")
                        MenuRow(icon: "bell", iconColor: .blue, title: "提醒", badge: "2")
                    }
                    
                    // 功能菜单 - 第二组
                    MenuSection {
                        MenuRow(icon: "tag", iconColor: .yellow, title: "标签管理")
                        MenuRow(icon: "paintpalette", iconColor: .red, title: "外观设置")
                    }
                    
                    // 账号设置
                    MenuSection {
                        MenuRow(icon: "person.circle", iconColor: .gray, title: "账号信息")
                        MenuRow(icon: "lock", iconColor: .indigo, title: "隐私设置")
                        MenuRow(icon: "questionmark.circle", iconColor: .teal, title: "帮助与反馈")
                        MenuRow(icon: "arrow.right.square", iconColor: .red, title: "退出登录", textColor: .red)
                    }
                }
                .padding()
            }
            .navigationTitle("个人中心")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(userName: $userName, userEmail: $userEmail, userAvatar: $userAvatar)
            }
        }
        .onAppear {
            // 模拟加载用户头像
            loadUserAvatar()
        }
    }
    
    private var uniqueCategories: [String] {
        Array(Set(items.map { $0.category }))
    }
    
    private func loadUserAvatar() {
        // 模拟从网络加载头像
        // 实际应用中应该从用户系统获取
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 使用系统默认头像
            userAvatar = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
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

struct MenuSection<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var badge: String? = nil
    var textColor: Color = .primary
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16))
            }
            
            Text(title)
                .foregroundColor(textColor)
                .padding(.leading, 8)
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .padding(.trailing, 4)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            // 处理点击事件
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var userAvatar: UIImage?
    
    @State private var tempName: String
    @State private var tempEmail: String
    @State private var showingImagePicker = false
    
    init(userName: Binding<String>, userEmail: Binding<String>, userAvatar: Binding<UIImage?>) {
        self._userName = userName
        self._userEmail = userEmail
        self._userAvatar = userAvatar
        self._tempName = State(initialValue: userName.wrappedValue)
        self._tempEmail = State(initialValue: userEmail.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let avatar = userAvatar {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("个人信息")) {
                    TextField("姓名", text: $tempName)
                    TextField("邮箱", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("修改密码") {
                        // 修改密码逻辑
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("编辑个人资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveChanges() {
        userName = tempName
        userEmail = tempEmail
        dismiss()
    }
}

#Preview {
    ProfileView(selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
