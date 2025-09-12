import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    let store: StoreOf<SearchFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Search Form
                        VStack(spacing: 16) {
                            Text("Flight Search")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            // Origin and Destination
                            HStack(spacing: 12) {
                                VStack(alignment: .leading) {
                                    Text("From")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("Origin", text: viewStore.binding(get: \.origin, send: { .originChanged($0) }))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("To")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("Destination", text: viewStore.binding(get: \.destination, send: { .destinationChanged($0) }))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            // Dates
                            HStack(spacing: 12) {
                                VStack(alignment: .leading) {
                                    Text("Departure")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    DatePicker("", selection: viewStore.binding(get: \.departureDate, send: { .departureDateChanged($0) }), displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Return")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    DatePicker("", selection: viewStore.binding(get: \.returnDate, send: { .returnDateChanged($0) }), displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                            }
                            
                            // Passengers
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Passengers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("Adults")
                                            .font(.caption)
                                        Stepper("\(viewStore.adults)", value: viewStore.binding(get: \.adults, send: { .adultsChanged($0) }), in: 1...9)
                                    }
                                    
                                    VStack {
                                        Text("Children")
                                            .font(.caption)
                                        Stepper("\(viewStore.children)", value: viewStore.binding(get: \.children, send: { .childrenChanged($0) }), in: 0...9)
                                    }
                                    
                                    VStack {
                                        Text("Infants")
                                            .font(.caption)
                                        Stepper("\(viewStore.infants)", value: viewStore.binding(get: \.infants, send: { .infantsChanged($0) }), in: 0...9)
                                    }
                                }
                            }
                            
                            // Travel Class
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Travel Class")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Travel Class", selection: viewStore.binding(get: \.travelClass, send: { .travelClassChanged($0) })) {
                                    Text("Economy").tag("ECONOMY")
                                    Text("Business").tag("BUSINESS")
                                    Text("First").tag("FIRST")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            // Search Button
                            Button(action: {
                                viewStore.send(.searchFlights)
                            }) {
                                HStack {
                                    if viewStore.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(viewStore.isLoading ? "Searching..." : "Search Flights")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(viewStore.isLoading)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        
                        // Results
                        if !viewStore.flightOffers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Available Flights")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                ForEach(viewStore.flightOffers) { offer in
                                    FlightOfferCard(offer: offer)
                                        .onTapGesture {
                                            viewStore.send(.selectOffer(offer))
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .navigationTitle("Flight Search")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}


#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
