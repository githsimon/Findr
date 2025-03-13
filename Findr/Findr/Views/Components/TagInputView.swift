import SwiftUI

struct TagInputView: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            // 显示已添加的标签
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    TagView(tag: tag) {
                        if let index = tags.firstIndex(of: tag) {
                            tags.remove(at: index)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            
            // 输入新标签
            HStack {
                TextField("添加标签", text: $newTag)
                    .focused($isFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        addTag()
                    }
                
                Button(action: addTag) {
                    Text("添加")
                }
                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespaces)
        if !tag.isEmpty && !tags.contains(tag) {
            tags.append(tag)
            newTag = ""
        }
    }
}

struct TagView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.subheadline)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}
