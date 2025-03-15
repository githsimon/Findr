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
    @State private var showingCancelAlert = false
    
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
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                    Text("点击添加照片")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
                }
                
                // 物品名称
                Section(header: Text("物品名称")) {
                    TextField("输入物品名称", text: $name)
                }
                
                // 分类
                Section(header: Text("分类")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: { 
                                        selectedCategory = category
                                        // 根据分类提供标签建议
                                        suggestTagsForCategory(category)
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                // 存放位置
                Section(header: Text("存放位置")) {
                    Picker("选择位置", selection: $selectedLocation) {
                        Text("请选择位置").tag(nil as Location?)
                        ForEach(locations) { location in
                            Text(location.name).tag(location as Location?)
                        }
                    }
                    .onChange(of: selectedLocation) { _, newLocation in
                        // 当位置改变时，重置子位置选择
                        selectedSublocation = ""
                        showingSublocations = newLocation?.sublocations.count ?? 0 > 0
                    }
                    
                    if let location = selectedLocation, !location.sublocations.isEmpty {
                        Picker("选择子位置", selection: $selectedSublocation) {
                            Text("请选择子位置").tag("")
                            ForEach(location.sublocationNames, id: \.self) { sublocationName in
                                Text(sublocationName).tag(sublocationName)
                            }
                        }
                        .onChange(of: selectedSublocation) { _, newSublocation in
                            if !newSublocation.isEmpty {
                                // 如果选择了子位置，将其添加到具体位置中
                                if specificLocation.isEmpty {
                                    specificLocation = newSublocation
                                } else if !specificLocation.contains(newSublocation) {
                                    specificLocation = "\(newSublocation) - \(specificLocation)"
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
                
                // 添加标签
                Section(header: Text("添加标签")) {
                    HStack {
                        TextField("输入标签", text: $tagText)
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(tagText.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    TagView(tag: tag) {
                                        if let index = tags.firstIndex(of: tag) {
                                            tags.remove(at: index)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
            .navigationTitle("添加物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        if !isFormEmpty() {
                            showingCancelAlert = true
                        } else {
                            cancelEditing()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveItem()
                    }
                    .disabled(!isFormValid())
                    .fontWeight(.semibold)
                }
            }
            .alert("确定要取消吗？", isPresented: $showingCancelAlert) {
                Button("放弃", role: .destructive) { cancelEditing() }
                Button("继续编辑", role: .cancel) { }
            } message: {
                Text("您输入的信息将不会被保存")
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .toast(isShowing: $showingToast, message: toastMessage, isSuccess: toastSuccess)
        }
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func suggestTagsForCategory(_ category: ItemCategory) {
        // 根据分类提供标签建议
        var suggestedTags: [String] = []
        
        switch category {
        case .clothing:
            suggestedTags = ["上衣", "裤子", "鞋子", "配饰"]
        case .kitchen:
            suggestedTags = ["餐具", "电器", "烹饪", "餐具"]
        case .books:
            suggestedTags = ["小说", "教材", "杂志", "参考书"]
        case .tools:
            suggestedTags = ["手工工具", "电动工具", "五金", "维修"]
        case .electronics:
            suggestedTags = ["手机", "电脑", "配件", "充电器"]
        case .stationery:
            suggestedTags = ["笔", "本子", "文件夹", "办公"]
        case .decoration:
            suggestedTags = ["相框", "摆件", "小物件", "季节性"]
        case .other:
            suggestedTags = ["杯子", "礼品", "纪念品", "收藏"]
        }
        
        // 如果标签列表为空，添加建议的标签
        if tags.isEmpty {
            // 随机选择2个标签添加
            let shuffledTags = suggestedTags.shuffled()
            for i in 0..<min(2, shuffledTags.count) {
                if !tags.contains(shuffledTags[i]) {
                    tags.append(shuffledTags[i])
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSpecificLocation = specificLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && selectedLocation != nil && !trimmedSpecificLocation.isEmpty
    }
    
    private func isFormEmpty() -> Bool {
        name.isEmpty && specificLocation.isEmpty && notes.isEmpty && selectedImageData == nil && tags.isEmpty
    }
    
    private func cancelEditing() {
        // 清空数据
        clearForm()
        dismiss()
    }
    
    private func clearForm() {
        name = ""
        selectedCategory = .clothing
        selectedLocation = nil
        specificLocation = ""
        selectedSublocation = ""
        notes = ""
        selectedImageData = nil
        tags = []
        tagText = ""
    }
    
    private func saveItem() {
        // 验证数据
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSpecificLocation = specificLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty && !trimmedSpecificLocation.isEmpty else {
            return
        }
        
        // 创建新物品
        let newItem = Item(
            name: trimmedName,
            category: selectedCategory.rawValue,
            location: selectedLocation,
            specificLocation: trimmedSpecificLocation,
            notes: notes.isEmpty ? nil : notes,
            imageData: selectedImageData,
            tagNames: tags
        )
        
        // 保存到数据库
        modelContext.insert(newItem)
        try? modelContext.save()
        
        // 如果选择了位置，将物品添加到位置的物品列表中
        if let location = selectedLocation {
            location.items.append(newItem)
            try? modelContext.save()
        }
        
        // 显示Toast提示
        toastMessage = "保存成功"
        toastSuccess = true
        showingToast = true
        
        // 清空数据
        clearForm()
        
        // 跳转到首页
        selectedTab = 0
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
                .padding(.leading, 8)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 4)
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}

#Preview {
    AddItemView(selectedTab: .constant(0))
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
