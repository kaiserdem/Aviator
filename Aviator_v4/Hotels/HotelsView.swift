import SwiftUI
import ComposableArchitecture

struct HotelsView: View {
    let store: StoreOf<HotelsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Градієнтний фон
                    AviationGradientBackground()
                    
                    VStack(spacing: 16) {
                        // Search Section
                        VStack(spacing: 12) {
                            TextField("Search hotels...", text: viewStore.binding(get: \.searchText, send: { .searchTextChanged($0) }))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Text("City:")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Picker("City", selection: viewStore.binding(get: \.selectedCity, send: { .cityChanged($0) })) {
                                    Text("Paris").tag("PAR")
                                    Text("London").tag("LON")
                                    Text("New York").tag("NYC")
                                    Text("Tokyo").tag("TYO")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                Button("Search") {
                                    viewStore.send(.searchHotels)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.black)
                            }
                        }
                        .padding()
                        
                        // Content
                        if viewStore.isLoading {
                            ProgressView("Searching hotels...")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = viewStore.errorMessage {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text("Error: \(errorMessage)")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.hotels.isEmpty {
                            VStack {
                                Image(systemName: "bed.double")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("No hotels found")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(viewStore.hotels) { hotel in
                                HotelRowView(hotel: hotel)
                            }
                        }
                    }
                    .navigationTitle("Hotels")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }
            }
        }
    }
}

struct HotelRowView: View {
    let hotel: Hotel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotel.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(hotel.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(hotel.currency) \(Int(hotel.price))")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<Int(hotel.rating), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                        if hotel.rating.truncatingRemainder(dividingBy: 1) > 0 {
                            Image(systemName: "star.leadinghalf.filled")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !hotel.amenities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(hotel.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HotelsView(
        store: Store(initialState: HotelsFeature.State()) {
            HotelsFeature()
        }
    )
}
