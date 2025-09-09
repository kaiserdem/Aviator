import SwiftUI
import ComposableArchitecture

private struct FlightRow: View {
    let flight: FlightState
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "airplane")
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(flight.callsign?.isEmpty == false ? flight.callsign! : "Без позивного")
                    .font(.headline)
                Text(flight.originCountry ?? "Невідома країна")
                    .foregroundStyle(.secondary)
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
                .navigationDestination(for: FlightState.self) { flight in
                    FlightDetailView(flight: flight)
                }
                .task { await viewStore.send(.onAppear).finish() }
            }
        }
    }
}


