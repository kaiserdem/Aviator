import SwiftUI
import ComposableArchitecture

struct SavedView: View {
    let store: StoreOf<SavedFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    if viewStore.savedSearches.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Saved Searches")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Save your favorite flight searches here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(viewStore.savedSearches) { search in
                            SavedSearchRowView(search: search)
                                .onTapGesture {
                                    viewStore.send(.selectSearch(search))
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Delete", role: .destructive) {
                                        viewStore.send(.removeSearch(search))
                                    }
                                }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Saved Searches")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct SavedSearchRowView: View {
    let search: SavedSearch
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(search.origin) → \(search.destination)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(search.travelClass)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Departure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: search.departureDate))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Return")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: search.returnDate))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            
            HStack {
                Text("Passengers: \(search.adults)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if search.children > 0 {
                    Text("+ \(search.children) children")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if search.infants > 0 {
                    Text("+ \(search.infants) infants")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Saved \(dateFormatter.string(from: search.createdAt))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SavedView(
        store: Store(initialState: SavedFeature.State()) {
            SavedFeature()
        }
    )
}
