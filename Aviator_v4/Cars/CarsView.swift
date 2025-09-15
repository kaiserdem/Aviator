import SwiftUI
import ComposableArchitecture

struct CarsView: View {
    let store: StoreOf<CarsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(spacing: 16) {
                    // Search Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Location:")
                            Picker("Location", selection: viewStore.binding(get: \.selectedLocation, send: { .locationChanged($0) })) {
                                Text("LAX").tag("LAX")
                                Text("JFK").tag("JFK")
                                Text("CDG").tag("CDG")
                                Text("LHR").tag("LHR")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Pickup Date")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                DatePicker("", selection: viewStore.binding(get: \.pickupDate, send: { .pickupDateChanged($0) }), displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Dropoff Date")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                DatePicker("", selection: viewStore.binding(get: \.dropoffDate, send: { .dropoffDateChanged($0) }), displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                        
                        Button("Search Cars") {
                            viewStore.send(.searchCars)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                    // Content
                    if viewStore.isLoading {
                        ProgressView("Searching cars...")
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
                    } else if viewStore.cars.isEmpty {
                        VStack {
                            Image(systemName: "car")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No cars found")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(viewStore.cars) { car in
                            CarRowView(car: car)
                        }
                    }
                }
                .navigationTitle("Car Rental")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct CarRowView: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(car.make) \(car.model)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(car.company)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(car.currency) \(Int(car.pricePerDay))/day")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text(car.category)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshift.2")
                        .foregroundColor(.gray)
                    Text(car.transmission)
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "fuelpump")
                        .foregroundColor(.gray)
                    Text(car.fuelType)
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .foregroundColor(.gray)
                    Text("\(car.seats) seats")
                        .font(.caption)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CarsView(
        store: Store(initialState: CarsFeature.State()) {
            CarsFeature()
        }
    )
}
