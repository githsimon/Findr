import SwiftUI

struct LocationPickerView: View {
    @Binding var selectedLocationId: String
    @StateObject private var locationViewModel = LocationViewModel()
    
    var body: some View {
        List {
            ForEach(locationViewModel.groupedLocations) { group in
                Section(header: Text(group.name)) {
                    ForEach(group.locations) { location in
                        LocationPickerRow(location: location, isSelected: selectedLocationId == location.id)
                            .onTapGesture {
                                selectedLocationId = location.id
                            }
                    }
                }
            }
        }
    }
}

struct LocationPickerRow: View {
    let location: Location
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.body)
                if location.type != .room {
                    Text(location.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
    }
}

// 预览
struct LocationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationPickerView(selectedLocationId: .constant(""))
                .navigationTitle("选择位置")
        }
    }
}
