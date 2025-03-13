import SwiftUI

struct LocationView: View {
    @EnvironmentObject var viewModel: LocationViewModel
    @State private var showingAddLocation = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groupedLocations) { group in
                    Section(header: Text(group.name)) {
                        ForEach(group.locations) { location in
                            LocationRowView(location: location)
                        }
                    }
                }
            }
            .navigationTitle("位置管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLocation = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView()
            }
        }
    }
}

struct LocationRowView: View {
    let location: Location
    @EnvironmentObject var viewModel: LocationViewModel
    
    var body: some View {
        NavigationLink(destination: LocationDetailView(location: location, viewModel: viewModel)) {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                if let parentName = viewModel.getParentLocationName(for: location) {
                    Text("在 \(parentName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
            .environmentObject(LocationViewModel())
    }
}
