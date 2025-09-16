import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    let store: StoreOf<SearchFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Градієнтний фон
                    AviationGradientBackground()
                    
                        VStack(spacing: 16) {
                            // Search Section
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("From:")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Picker("Origin", selection: viewStore.binding(get: \.origin, send: { .originChanged($0) })) {
                                            Text("New York (NYC)").tag("NYC")
                                            Text("Los Angeles (LAX)").tag("LAX")
                                            Text("Chicago (ORD)").tag("ORD")
                                            Text("Miami (MIA)").tag("MIA")
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("To:")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Picker("Destination", selection: viewStore.binding(get: \.destination, send: { .destinationChanged($0) })) {
                                            Text("Los Angeles (LAX)").tag("LAX")
                                            Text("New York (NYC)").tag("NYC")
                                            Text("Chicago (ORD)").tag("ORD")
                                            Text("Miami (MIA)").tag("MIA")
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Departure Date")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        DatePicker("", selection: viewStore.binding(get: \.departureDate, send: { .departureDateChanged($0) }), displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Passengers")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Stepper("\(viewStore.passengers)", value: viewStore.binding(get: \.passengers, send: { .passengersChanged($0) }), in: 1...9)
                                            .labelsHidden()
                                    }
                                }
                                
                                Button("Search Flights") {
                                    viewStore.send(.searchFlights)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.buttonTextColor)
                            }
                            .padding()
                            
                            // Content
                            if viewStore.isLoading {
                                ProgressView("Searching flights...")
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
                            } else if viewStore.flights.isEmpty {
                                VStack {
                                    Image(systemName: "airplane")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No flights found")
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                List(viewStore.flights) { flight in
                                    FlightRowView(flight: flight)
                                }
                            }
                        }
                    }
                .navigationTitle("Flights")
                .navigationBarTitleDisplayMode(.large)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
            .id("tab3Navigation")
        }
    }
}

struct FlightRowView: View {
    let flight: Flight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(flight.airline) \(flight.flightNumber)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(flight.origin) → \(flight.destination)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(flight.currency) \(flight.price)")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text(flight.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Departure")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(flight.formattedDepartureTime)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("Duration")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(flight.formattedDuration)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Arrival")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(flight.formattedArrivalTime)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            if flight.stops > 0 {
                HStack {
                    Image(systemName: "airplane")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("\(flight.stops) stop\(flight.stops == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
                        SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
