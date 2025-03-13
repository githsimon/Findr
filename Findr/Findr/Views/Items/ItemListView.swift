import SwiftUI

struct ItemListView: View {
    @EnvironmentObject var viewModel: ItemListViewModel
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    ItemRowView(item: item)
                }
            }
            .navigationTitle("物品清单")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }
}

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(item: item)) {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
    }
}
