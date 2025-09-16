import SwiftUI
import ComposableArchitecture

struct Tab4View: View {
    let store: StoreOf<Tab4Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    // Градієнтний фон
                    AviationGradientBackground()
                    
                        VStack(spacing: 16) {
                            // Search Section
                            VStack(spacing: 12) {
                                TextField("Enter flight number (e.g., UA123)", text: viewStore.binding(get: \.searchText, send: { .searchTextChanged($0) }))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.allCharacters)
                                    .disableAutocorrection(true)
                                
                                Button("Track Flight") {
                                    viewStore.send(.trackFlight)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white)
                                .foregroundColor(.buttonTextColor)
                                .disabled(viewStore.searchText.isEmpty)
                            }
                            .padding()
                            
                            // Content
                            if viewStore.isLoading {
                                ProgressView("Tracking flight...")
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
                            } else if let flightStatus = viewStore.flightStatus {
                                FlightStatusDetailView(flightStatus: flightStatus)
                            } else if viewStore.trackedFlights.isEmpty {
                                VStack {
                                    Image(systemName: "airplane.departure")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No tracked flights")
                                        .foregroundColor(.white)
                                    Text("Enter a flight number to start tracking")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                List {
                                    Section("Tracked Flights") {
                                        ForEach(viewStore.trackedFlights) { flightStatus in
                                            FlightStatusRowView(flightStatus: flightStatus) {
                                                viewStore.send(.removeFromTracked(flightStatus.flightNumber))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                .navigationTitle("Flight Tracker")
                .navigationBarTitleDisplayMode(.large)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
            .id("tab4Navigation")
        }
    }
}

struct FlightStatusDetailView: View {
    let flightStatus: FlightStatus
    
    var body: some View {
        VStack(spacing: 16) {
            // Flight Header
            VStack(spacing: 8) {
                Text(flightStatus.flightNumber)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(flightStatus.origin) → \(flightStatus.destination)")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(flightStatus.status)
                    .font(.headline)
                    .foregroundColor(flightStatus.statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(flightStatus.statusColor.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Flight Details
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Departure")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(flightStatus.formattedScheduledDeparture)
                            .font(.headline)
                        if let actualDeparture = flightStatus.formattedActualDeparture {
                            Text("Actual: \(actualDeparture)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Arrival")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(flightStatus.formattedScheduledArrival)
                            .font(.headline)
                        if let actualArrival = flightStatus.formattedActualArrival {
                            Text("Actual: \(actualArrival)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                if let gate = flightStatus.gate, let terminal = flightStatus.terminal {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(gate)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Terminal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(terminal)
                                .font(.headline)
                        }
                    }
                }
                
                if let aircraft = flightStatus.aircraft {
                    HStack {
                        Text("Aircraft:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(aircraft)
                            .font(.headline)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
}

struct FlightStatusRowView: View {
    let flightStatus: FlightStatus
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(flightStatus.flightNumber)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(flightStatus.origin) → \(flightStatus.destination)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(flightStatus.status)
                    .font(.caption)
                    .foregroundColor(flightStatus.statusColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(flightStatus.formattedScheduledDeparture)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let gate = flightStatus.gate {
                    Text("Gate \(gate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Tab4View(
        store: Store(initialState: Tab4Feature.State()) {
            Tab4Feature()
        }
    )
}
