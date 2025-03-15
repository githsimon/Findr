//
//  EditItemView.swift
//  FindrIOS
//
//  Created on 2025/3/15.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var locations: [Location]
    
    // 编辑的物品
    var item: Item
    
    // 用于跳转到首页
    @Binding var selectedTab: Int
    
    // Toast提示相关状态
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = true
    
    // 表单数据
    @State private var name = ""
    @State private var selectedCategory: ItemCategory = .clothing
    @State private var selectedLocation: Location?
    @State private var specificLocation = ""
    @State private var showingSublocations = false
    @State private var selectedSublocation = ""
    @State private var notes = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var tagText = ""
    @State private var tags: [String] = []
    @State private var isFavorite: Bool = false
    @State private var showingCancelAlert = false
    @State private var showingDeleteAlert = false
    
    init(item: Item, selectedTab: Binding<Int>) {
        self.item = item
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        let formContent = Form {
            // 物品照片
            Section(header: Text("物品照片")) {
                VStack {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text(selectedImageData == nil ? "选择照片" : "更换照片")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                }
                .padding(.vertical)
            }
            
            // 基本信息
            Section(header: Text("基本信息")) {
                TextField("物品名称", text: $name)
                
                // 分类选择
                VStack(alignment: .leading) {
                    Text("分类")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                CategoryButton(category: category, isSelected: selectedCategory == category, action: {
                                    selectedCategory = category
                                })
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // 收藏标记
                Toggle("收藏", isOn: $isFavorite)
            }
            
            // 位置信息
            Section(header: Text("位置信息")) {
                Picker("选择位置", selection: $selectedLocation) {
                    Text("无")
                        .tag(nil as Location?)
                    
                    ForEach(locations) { location in
                        Text(location.name)
                            .tag(location as Location?)
                    }
                }
                .onChange(of: selectedLocation) { _, _ in
                    selectedSublocation = ""
                }
                
                if let location = selectedLocation, !location.sublocations.isEmpty {
                    Picker("选择子位置", selection: $selectedSublocation) {
                        Text("无")
                            .tag("")
                        
                        ForEach(location.sublocationNames, id: \.self) { sublocation in
                            Text(sublocation)
                                .tag(sublocation)
                        }
                    }
                }
            }
            
            // 具体位置
            Section(header: Text("具体位置")) {
                TextField("例如：第二层右侧", text: $specificLocation)
                if selectedLocation != nil && selectedSublocation.isEmpty {
                    Text("提示：可以先选择子位置，然后再补充具体位置")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // 标签
            Section(header: Text("标签")) {
                HStack {
                    TextField("添加标签", text: $tagText)
                        .submitLabel(.done)
                        .onSubmit {
                            addTag()
                        }
                    
                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(tagText.isEmpty)
                }
                
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            
                            Button(action: {
                                if let index = tags.firstIndex(of: tag) {
                                    tags.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                    }
                }
            }
            
            // 备注
            Section(header: Text("备注")) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            // 删除按钮
            Section {
                Button("删除物品", role: .destructive) {
                    showingDeleteAlert = true
                }
            }
        }
        
        return NavigationStack {
            formContent
                .navigationTitle("编辑物品")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("取消") {
                            if hasChanges() {
                                showingCancelAlert = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("保存") {
                            saveItem()
                        }
                    }
                })
                .onAppear {
                    // 加载物品数据
                    loadItemData()
                }
                .alert("确定放弃更改？", isPresented: $showingCancelAlert) {
                    Button("放弃", role: .destructive) {
                        dismiss()
                    }
                    Button("继续编辑", role: .cancel) {}
                }
                .alert("确定删除此物品？", isPresented: $showingDeleteAlert) {
                    Button("删除", role: .destructive) {
                        deleteItem()
                    }
                    Button("取消", role: .cancel) {}
                }
                .overlay {
                    if showingToast {
                        ToastView(message: toastMessage, isSuccess: toastSuccess)
                            .padding()
                            .transition(.move(edge: .top))
                    }
                }
        }
    }
    
    private func loadItemData() {
        // 加载物品数据到表单
        name = item.name
        selectedCategory = ItemCategory.allCases.first(where: { $0.rawValue == item.category }) ?? .other
        selectedLocation = item.location
        specificLocation = item.specificLocation
        notes = item.notes ?? ""
        selectedImageData = item.imageData
        tags = item.tagNames
        isFavorite = item.isFavorite
        
        // 如果有子位置，尝试找到匹配的子位置
        if let location = selectedLocation, !specificLocation.isEmpty {
            for sublocationName in location.sublocationNames {
                if specificLocation.contains(sublocationName) {
                    selectedSublocation = sublocationName
                    break
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func hasChanges() -> Bool {
        return name != item.name ||
        selectedCategory.rawValue != item.category ||
        selectedLocation != item.location ||
        specificLocation != item.specificLocation ||
        notes != (item.notes ?? "") ||
        selectedImageData != item.imageData ||
        tags != item.tagNames ||
        isFavorite != item.isFavorite
    }
    
    private func saveItem() {
        // 验证必填字段
        guard !name.isEmpty else {
            showToast(message: "请输入物品名称", success: false)
            return
        }
        
        guard !specificLocation.isEmpty else {
            showToast(message: "请输入具体位置", success: false)
            return
        }
        
        // 更新物品数据
        item.name = name
        item.category = selectedCategory.rawValue
        item.location = selectedLocation
        item.specificLocation = specificLocation
        item.notes = notes.isEmpty ? nil : notes
        item.imageData = selectedImageData
        item.isFavorite = isFavorite
        
        // 更新标签
        // 先删除所有旧标签
        item.tags.forEach { modelContext.delete($0) }
        item.tags = []
        
        // 添加新标签
        for tagName in tags {
            item.addTag(tagName)
        }
        
        // 保存更改
        do {
            try modelContext.save()
            showToast(message: "物品已更新", success: true)
            
            // 延迟关闭页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }
        } catch {
            showToast(message: "保存失败: \(error.localizedDescription)", success: false)
        }
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        
        do {
            try modelContext.save()
            showToast(message: "物品已删除", success: true)
            
            // 延迟关闭页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
                selectedTab = 0 // 返回首页
            }
        } catch {
            showToast(message: "删除失败: \(error.localizedDescription)", success: false)
        }
    }
    
    private func showToast(message: String, success: Bool) {
        toastMessage = message
        toastSuccess = success
        
        withAnimation {
            showingToast = true
        }
        
        // 自动隐藏Toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingToast = false
            }
        }
    }
}

#Preview {
    EditItemView(item: Item(name: "测试物品", category: "衣物", specificLocation: "衣柜"), selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, Tag.self], inMemory: true)
}
