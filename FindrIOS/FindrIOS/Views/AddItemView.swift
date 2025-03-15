//
//  AddItemView.swift
//  FindrIOS
//
//  Created on 2025/3/14.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var locations: [Location]
    
    // 用于跳转到首页
    @Binding var selectedTab: Int
    
    // 编辑模式相关
    var item: Item? // 如果是编辑模式，则传入物品
    var isEditMode: Bool { item != nil }
    
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
    @State private var selectedImageData: Data? = nil
    @State private var tagText = ""
    @State private var tags: [String] = []
    @State private var showingCancelAlert = false
    @State private var showingDeleteAlert = false
    @State private var isFavorite = false
    
    var body: some View {
        NavigationStack {
            Form {
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
                            
                            Button("更换照片") {
                                // 使用状态变量更新图片
                                self.selectedImageData = nil
                            }
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("添加照片")
                                        .foregroundColor(.blue)
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .onChange(of: selectedItem) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                }
                            }
                        }
                    }
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
                    .onChange(of: selectedLocation) { _, newLocation in
                        // 清空子位置选择
                        selectedSublocation = ""
                        
                        // 如果新选择的位置有子位置，显示子位置选择
                        showingSublocations = newLocation?.sublocations.count ?? 0 > 0
                    }
                    
                    if showingSublocations {
                        Picker("选择子位置", selection: $selectedSublocation) {
                            Text("无")
                                .tag("")
                            
                            if let location = selectedLocation {
                                ForEach(location.sublocationNames, id: \.self) { sublocation in
                                    Text(sublocation)
                                        .tag(sublocation)
                                }
                            }
                        }
                        .onChange(of: selectedSublocation) { _, newSublocation in
                            if !newSublocation.isEmpty {
                                // 将子位置添加到具体位置
                                if specificLocation.isEmpty {
                                    specificLocation = newSublocation
                                } else if !specificLocation.contains(newSublocation) {
                                    specificLocation = "\(newSublocation), \(specificLocation)"
                                }
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
                
                // 备注
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
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
                            TagView(tag: tag) {
                                if let index = tags.firstIndex(of: tag) {
                                    tags.remove(at: index)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                // 删除按钮（仅编辑模式显示）
                if isEditMode {
                    Section {
                        Button("删除物品", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(isEditMode ? "编辑物品" : "添加物品")
            .toolbar {
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
                        .transition(.move(edge: .bottom))
                }
            }
            .onAppear {
                if isEditMode, let item = item {
                    loadItemData(from: item)
                }
            }
        }
    }
    
    // 添加标签
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    // 判断表单是否有变化
    private func hasChanges() -> Bool {
        if isEditMode, let item = item {
            return name != item.name ||
            selectedCategory.rawValue != item.category ||
            selectedLocation != item.location ||
            specificLocation != item.specificLocation ||
            notes != (item.notes ?? "") ||
            selectedImageData != item.imageData ||
            tags != item.tagNames ||
            isFavorite != item.isFavorite
        } else {
            return !name.isEmpty || selectedImageData != nil || !specificLocation.isEmpty || !notes.isEmpty || !tags.isEmpty || isFavorite
        }
    }
    
    // 从物品加载数据到表单
    private func loadItemData(from item: Item) {
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
            showingSublocations = location.sublocations.count > 0
            for sublocationName in location.sublocationNames {
                if specificLocation.contains(sublocationName) {
                    selectedSublocation = sublocationName
                    break
                }
            }
        }
    }
    
    // 保存物品
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
        
        if isEditMode, let existingItem = item {
            // 更新现有物品
            existingItem.name = name
            existingItem.category = selectedCategory.rawValue
            existingItem.location = selectedLocation
            existingItem.specificLocation = specificLocation
            existingItem.notes = notes.isEmpty ? nil : notes
            existingItem.imageData = selectedImageData
            existingItem.isFavorite = isFavorite
            
            // 更新标签
            // 先删除所有旧标签
            existingItem.tags.forEach { modelContext.delete($0) }
            existingItem.tags = []
            
            // 添加新标签
            for tagName in tags {
                existingItem.addTag(tagName)
            }
            
            showToast(message: "物品已更新", success: true)
        } else {
            // 创建新物品
            let newItem = Item(
                name: name,
                category: selectedCategory.rawValue,
                location: selectedLocation,
                specificLocation: specificLocation,
                notes: notes.isEmpty ? nil : notes,
                imageData: selectedImageData,
                tagNames: tags,
                timestamp: Date()
            )
            newItem.isFavorite = isFavorite
            
            // 添加到数据库
            modelContext.insert(newItem)
            showToast(message: "物品已添加", success: true)
        }
        
        // 保存更改
        do {
            try modelContext.save()
            
            // 延迟关闭页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
                if !isEditMode {
                    selectedTab = 0 // 返回首页
                }
            }
        } catch {
            showToast(message: "保存失败: \(error.localizedDescription)", success: false)
        }
    }
    
    // 删除物品
    private func deleteItem() {
        guard isEditMode, let item = item else { return }
        
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
    
    // 显示Toast提示
    private func showToast(message: String, success: Bool) {
        toastMessage = message
        toastSuccess = success
        
        withAnimation {
            showingToast = true
        }
        
        // 2秒后隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showingToast = false
            }
        }
    }
}

struct CategoryButton: View {
    let category: ItemCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? category.color : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}
