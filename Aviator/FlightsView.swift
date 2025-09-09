import SwiftUI

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
    @State private var isLoading: Bool = true
    @State private var flights: [FlightState] = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Завантаження…")
                } else if flights.isEmpty {
                    ContentUnavailableView("Немає даних", systemImage: "airplane", description: Text("Спробуйте пізніше"))
                } else {
                    List(flights) { flight in
                        FlightRow(flight: flight)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Рейси")
            .task {
                isLoading = true
                let data = await NetworkService.shared.fetchOpenSkyStates()
                flights = data
                isLoading = false
            }
        }
    }
}

#Preview {
    FlightsView()
}


