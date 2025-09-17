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
                                        TextField("Enter origin (e.g., Paris, NYC)", text: viewStore.binding(get: \.origin, send: { .originChanged($0) }))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.allCharacters)
                                            .disableAutocorrection(true)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("To:")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        TextField("Enter destination (e.g., Sofia, LAX)", text: viewStore.binding(get: \.destination, send: { .destinationChanged($0) }))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.allCharacters)
                                            .disableAutocorrection(true)
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
                                .disabled(viewStore.origin.isEmpty || viewStore.destination.isEmpty)
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
                            } else if viewStore.flights.isEmpty && viewStore.hasSearched {
                                // Красива заглушка для пустого списку після пошуку
                                VStack(spacing: 20) {
                                    Image(systemName: "airplane.departure")
                                        .font(.system(size: 80))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    VStack(spacing: 8) {
                                        Text("No flights found")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("Try adjusting your search criteria")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                        
                                        Text("• Check airport codes (e.g., NYC, LAX)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Text("• Try different dates")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Text("• Verify airport names")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Button("Search Again") {
                                        viewStore.send(.searchFlights)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.white)
                                    .foregroundColor(.buttonTextColor)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                            } else if viewStore.flights.isEmpty && !viewStore.hasSearched {
                                // Початковий стан - ще не було пошуку
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 80))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    VStack(spacing: 8) {
                                        Text("Search for flights")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("Enter your travel details above to find available flights")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                        
                                        Text("💡 Tip: You can enter city names (Paris, Sofia) or airport codes (CDG, SOF)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.top, 8)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                            } else {
                                List(viewStore.flights) { flight in
                                    NavigationLink(destination: FlightDetailView(flight: flight)) {
                                        FlightRowView(flight: flight)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
