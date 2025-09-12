import SwiftUI
import ComposableArchitecture

struct SavedView: View {
    let store: StoreOf<SavedFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
                    Theme.Gradient.background
                        .ignoresSafeArea()
                    
                    VStack {
                        if viewStore.savedSearches.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.Palette.primaryRed)
                                
                                Text("No Saved Searches")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Palette.textPrimary)
                                
                                Text("Save your favorite flight searches here")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Palette.textSecondary)
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
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .navigationTitle("Saved Searches")
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(Theme.Gradient.navigationBar, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .foregroundColor(Theme.Palette.textPrimary)
                
                Spacer()
                
                Text(search.travelClass)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Palette.primaryRed.opacity(0.2))
                    .foregroundColor(Theme.Palette.primaryRed)
                    .cornerRadius(4)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Departure")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                    Text(dateFormatter.string(from: search.departureDate))
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Return")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                    Text(dateFormatter.string(from: search.returnDate))
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textPrimary)
                }
            }
            
            HStack {
                Text("Passengers: \(search.adults)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                
                if search.children > 0 {
                    Text("+ \(search.children) children")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                if search.infants > 0 {
                    Text("+ \(search.infants) infants")
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                Spacer()
                
                Text("Saved \(dateFormatter.string(from: search.createdAt))")
                    .font(.caption2)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
        }
        .padding(.vertical, 4)
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Shadow.red, radius: 2)
    }
}

#Preview {
    SavedView(
        store: Store(initialState: SavedFeature.State()) {
            SavedFeature()
        }
    )
}
