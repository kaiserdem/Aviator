import SwiftUI
import ComposableArchitecture

struct ResultsView: View {
    let store: StoreOf<ResultsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    if viewStore.isLoading {
                        ProgressView("Loading results...")
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
                                
                                Spacer()
                                
                                // Filter Picker
                                Picker("Filter", selection: viewStore.binding(get: \.filterOption, send: { .filterChanged($0) })) {
                                    ForEach(ResultsFeature.FilterOption.allCases, id: \.self) { option in
                                        Text(option.displayName).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding()
                            
                            // Results List
                            List(filteredAndSortedOffers(viewStore.flightOffers, sortOption: viewStore.sortOption, filterOption: viewStore.filterOption)) { offer in
                                FlightOfferCard(offer: offer)
                                    .onTapGesture {
                                        viewStore.send(.selectOffer(offer))
                                    }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
                .navigationTitle("Flight Results")
                .onAppear {
                    viewStore.send(.onAppear)
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
            filtered.sort { Int($0.price) ?? 0 < Int($1.price) ?? 0 }
        case .duration:
            filtered.sort { $0.duration < $1.duration }
        case .departure:
            filtered.sort { $0.departureDate < $1.departureDate }
        }
        
        return filtered
    }
}

struct FlightOfferCard: View {
    let offer: FlightOffer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(offer.origin) → \(offer.destination)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(offer.airline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(offer.price) \(offer.currency)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(offer.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Flight: \(offer.flightNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(offer.stops == 0 ? "Direct" : "\(offer.stops) stop(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    ResultsView(
        store: Store(initialState: ResultsFeature.State()) {
            ResultsFeature()
        }
    )
}
