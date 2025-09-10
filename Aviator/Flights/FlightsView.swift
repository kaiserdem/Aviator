import SwiftUI
import ComposableArchitecture

private struct FlightRow: View {
    let flight: FlightState
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            // Aircraft image or icon
            if let imageURL = flight.aircraftImageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "airplane")
                        .foregroundStyle(.tint)
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "airplane")
                    .foregroundStyle(.tint)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(flight.callsign?.isEmpty == false ? flight.callsign! : "Unknown callsign")
                    .font(.title3)
                Text(flight.originCountry ?? "Unknown country")
                    .foregroundStyle(.secondary)
                if let aircraftType = flight.aircraftType {
                    Text(aircraftType)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            if let v = flight.velocity {
                Text(String(format: "%.0f km/h", v * 3.6))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct FlightsView: View {
    let store: StoreOf<FlightsFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    if viewStore.isLoading {
                        ProgressView("Loading…")
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                    } else if viewStore.flights.isEmpty {
                        ContentUnavailableView("No data", systemImage: "airplane", description: Text("Please try again later"))
                    } else {
                        List(viewStore.flights) { flight in
                            NavigationLink(value: flight) {
                                FlightRow(flight: flight)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("Flights")
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
                .navigationDestination(for: FlightState.self) { flight in
                    FlightDetailView(flight: flight)
                }
                .task { await viewStore.send(.onAppear).finish() }
            }
        }
    }
}


