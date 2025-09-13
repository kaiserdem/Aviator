import SwiftUI
import ComposableArchitecture

struct SavedView: View {
    let store: StoreOf<SavedFeature>
    let onGoToSearch: () -> Void
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
                    Theme.Gradient.background
                        .ignoresSafeArea()
                    
                    VStack {
                        if viewStore.isLoading {
                            ProgressView("Loading saved flights...")
                                .foregroundColor(Theme.Palette.textPrimary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.savedFlights.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "bookmark.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(Theme.Palette.primaryRed)
                                
                                VStack(spacing: 12) {
                                    Text("No Saved Flights Yet")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Palette.textPrimary)
                                    
                                    Text("Save flights from search results to see them here")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                
                                Button(action: {
                                    onGoToSearch()
                                }) {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                        Text("Go to Search")
                                    }
                                    .font(.headline)
                                    .foregroundColor(Theme.Palette.textPrimary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Theme.Palette.primaryRed)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(viewStore.savedFlights) { savedFlight in
                                NavigationLink(destination: FlightDetailView(flightOffer: savedFlight.flightOffer)) {
                                    SavedFlightRowView(savedFlight: savedFlight)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Delete", role: .destructive) {
                                        viewStore.send(.deleteFlight(savedFlight))
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .navigationTitle("Saved Flights")
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(Theme.Gradient.navigationBar, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Refresh") {
                            viewStore.send(.refresh)
                        }
                        .foregroundColor(Theme.Palette.primaryRed)
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}


struct SavedFlightRowView: View {
    let savedFlight: SavedFlight
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(savedFlight.flightOffer.origin) → \(savedFlight.flightOffer.destination)")
                    .font(.headline)
                    .foregroundColor(Theme.Palette.textPrimary)
                
                Spacer()
                
                Text("\(savedFlight.flightOffer.price) \(savedFlight.flightOffer.currency)")
                    .font(.headline)
                    .foregroundColor(Theme.Palette.primaryRed)
            }
            
            HStack {
                Text(savedFlight.flightOffer.airline)
                    .font(.subheadline)
                    .foregroundColor(Theme.Palette.textSecondary)
                
                Text("• \(savedFlight.flightOffer.flightNumber)")
                    .font(.subheadline)
                    .foregroundColor(Theme.Palette.textSecondary)
                
                Spacer()
                
                Text(stopsText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Palette.primaryRed.opacity(0.2))
                    .foregroundColor(Theme.Palette.primaryRed)
                    .cornerRadius(4)
            }
            
            HStack {
                Text("Duration: \(savedFlight.flightOffer.duration)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textTertiary)
                
                Spacer()
                
                Text("Saved \(dateFormatter.string(from: savedFlight.savedAt))")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textTertiary)
            }
            
            if let notes = savedFlight.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textTertiary)
                    .italic()
            }
        }
        .padding()
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Shadow.red, radius: 4)
    }
    
    private var stopsText: String {
        switch savedFlight.flightOffer.stops {
        case 0:
            return "Direct"
        case 1:
            return "1 stop"
        default:
            return "\(savedFlight.flightOffer.stops) stops"
        }
    }
}

#Preview {
    SavedView(
        store: Store(initialState: SavedFeature.State()) {
            SavedFeature()
        },
        onGoToSearch: {}
    )
}
