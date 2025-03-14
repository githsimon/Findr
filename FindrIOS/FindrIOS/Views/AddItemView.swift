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
    
    @State private var name = ""
    @State private var selectedCategory: ItemCategory = .clothing
    @State private var selectedLocation: Location?
    @State private var specificLocation = ""
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
                                    action: { selectedCategory = category }
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
                }
                
                // 具体位置
                Section(header: Text("具体位置")) {
                    TextField("例如：第二层右侧", text: $specificLocation)
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
                            dismiss()
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
                Button("放弃", role: .destructive) { dismiss() }
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
        }
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func isFormValid() -> Bool {
        !name.isEmpty && selectedLocation != nil && !specificLocation.isEmpty
    }
    
    private func isFormEmpty() -> Bool {
        name.isEmpty && specificLocation.isEmpty && notes.isEmpty && selectedImageData == nil && tags.isEmpty
    }
    
    private func saveItem() {
        let newItem = Item(
            name: name,
            category: selectedCategory.rawValue,
            location: selectedLocation,
            specificLocation: specificLocation,
            notes: notes.isEmpty ? nil : notes,
            imageData: selectedImageData,
            tags: tags
        )
        
        modelContext.insert(newItem)
        dismiss()
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
    AddItemView()
        .modelContainer(for: [Item.self, Location.self, ItemTag.self], inMemory: true)
}
