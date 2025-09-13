import SwiftUI
import ComposableArchitecture

struct ResultsView: View {
    let store: StoreOf<ResultsFeature>
    let onGoToSearch: () -> Void
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Background gradient
                    Theme.Gradient.background
                        .ignoresSafeArea()
                    
                    VStack {
                        if viewStore.isLoading {
                            ProgressView("Loading results...")
                                .foregroundColor(Theme.Palette.textPrimary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.flightOffers.isEmpty {
                            // Empty state when no search has been performed
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(Theme.Palette.primaryRed)
                                
                                VStack(spacing: 12) {
                                    Text("No Search Results Yet")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Palette.textPrimary)
                                    
                                    Text("Enter your search criteria on the Search tab to find flights")
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
                            let filteredOffers = filteredAndSortedOffers(viewStore.flightOffers, sortOption: viewStore.sortOption, filterOption: viewStore.filterOption)
                            
                            if filteredOffers.isEmpty {
                                // Empty state when filters return no results
                                VStack(spacing: 20) {
                                    Image(systemName: "airplane.circle")
                                        .font(.system(size: 80))
                                        .foregroundColor(Theme.Palette.primaryRed)
                                    
                                    VStack(spacing: 12) {
                                        Text("No Flights Match Your Filters")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.Palette.textPrimary)
                                        
                                        Text("Try adjusting your filters to see more results")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.Palette.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                    
                                    Button(action: {
                                        viewStore.send(.resetFilters)
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Reset Filters")
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
                                VStack {
                                    // Sort and Filter Controls
                                    HStack {
                                        // Sort Picker
                                        Picker("Sort by", selection: viewStore.binding(get: \.sortOption, send: { .sortChanged($0) })) {
                                            ForEach(ResultsFeature.SortOption.allCases, id: \.self) { option in
                                                Text(option.displayName).tag(option)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .colorScheme(.dark)
                                        
                                        Spacer()
                                        
                                        // Filter Picker
                                        Picker("Filter", selection: viewStore.binding(get: \.filterOption, send: { .filterChanged($0) })) {
                                            ForEach(ResultsFeature.FilterOption.allCases, id: \.self) { option in
                                                Text(option.displayName).tag(option)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .colorScheme(.dark)
                                    }
                                    .padding()
                                    .background(Theme.Gradient.surface)
                                    .cornerRadius(12)
                                    .shadow(color: Theme.Shadow.red, radius: 4)
                                    .padding()
                                    
                                    // Results List
                                    List(filteredOffers) { offer in
                                        NavigationLink(destination: FlightDetailView(flightOffer: offer)) {
                                            SavedFlightOfferCard(offer: offer)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .listStyle(PlainListStyle())
                                    .scrollContentBackground(.hidden)
                                }
                            }
                        }
                    }
                    .navigationTitle("Flight Results")
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
    
    private func filteredAndSortedOffers(_ offers: [FlightOffer], sortOption: ResultsFeature.SortOption, filterOption: ResultsFeature.FilterOption) -> [FlightOffer] {
        var filtered = offers
        
        // Apply filter
        switch filterOption {
        case .all:
            break
        case .direct:
            filtered = offers.filter { $0.stops == 0 }
        case .oneStop:
            filtered = offers.filter { $0.stops == 1 }
        case .twoStops:
            filtered = offers.filter { $0.stops >= 2 }
        }
        
        // Apply sort
        switch sortOption {
        case .price:
            filtered.sort { 
                let price1 = Double($0.price.replacingOccurrences(of: ",", with: "")) ?? 0
                let price2 = Double($1.price.replacingOccurrences(of: ",", with: "")) ?? 0
                return price1 < price2
            }
        case .duration:
            filtered.sort { 
                let duration1 = parseDuration($0.duration)
                let duration2 = parseDuration($1.duration)
                return duration1 < duration2
            }
        case .departure:
            filtered.sort { 
                let date1 = parseDate($0.departureDate)
                let date2 = parseDate($1.departureDate)
                return date1 < date2
            }
        }
        
        return filtered
    }
    
    private func parseDuration(_ duration: String) -> Int {
        // Parse duration like "PT5H15M" to minutes
        let components = duration.replacingOccurrences(of: "PT", with: "")
        var totalMinutes = 0
        
        if let hoursRange = components.range(of: "H") {
            let hoursString = String(components[..<hoursRange.lowerBound])
            if let hours = Int(hoursString) {
                totalMinutes += hours * 60
            }
        }
        
        if let minutesRange = components.range(of: "M") {
            let minutesString = String(components[components.index(after: components.lastIndex(of: "H") ?? components.startIndex)..<minutesRange.lowerBound])
            if let minutes = Int(minutesString) {
                totalMinutes += minutes
            }
        }
        
        return totalMinutes
    }
    
    private func parseDate(_ dateString: String) -> Date {
        // Parse date like "2024-01-15T10:30:00"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: dateString) ?? Date()
    }
}

struct SavedFlightOfferCard: View {
    let offer: FlightOffer
    @Dependency(\.databaseClient) var databaseClient
    @State private var isSaved = false
    
    var body: some View {
        FlightOfferCard(offer: offer, isSaved: isSaved)
            .onAppear {
                Task {
                    do {
                        let savedStatus = try await databaseClient.isFlightSaved(offer)
                        print("🔍 Checking flight \(offer.flightNumber): isSaved = \(savedStatus)")
                        isSaved = savedStatus
                    } catch {
                        print("❌ Error checking if flight is saved: \(error)")
                    }
                }
            }
    }
}

struct FlightOfferCard: View {
    let offer: FlightOffer
    let isSaved: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(offer.origin) → \(offer.destination)")
                            .font(.headline)
                            .foregroundColor(Theme.Palette.textPrimary)
                        
                        if isSaved {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(Theme.Palette.primaryRed)
                                .font(.caption)
                        }
                    }
                    
                    Text(offer.airline)
                        .font(.subheadline)
                        .foregroundColor(Theme.Palette.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(offer.price) \(offer.currency)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Palette.gold)
                    
                    Text(offer.duration)
                        .font(.caption)
                        .foregroundColor(Theme.Palette.textSecondary)
                }
            }
            
            HStack {
                Text("Flight: \(offer.flightNumber)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
                
                Spacer()
                
                Text(offer.stops == 0 ? "Direct" : "\(offer.stops) stop(s)")
                    .font(.caption)
                    .foregroundColor(Theme.Palette.textSecondary)
            }
        }
        .padding()
        .background(Theme.Gradient.surface)
        .cornerRadius(12)
        .shadow(color: Theme.Shadow.red, radius: 2)
    }
}

#Preview {
    ResultsView(
        store: Store(initialState: ResultsFeature.State()) {
            ResultsFeature()
        },
        onGoToSearch: {}
    )
}
