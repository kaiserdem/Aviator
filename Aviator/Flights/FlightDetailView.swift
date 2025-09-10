import SwiftUI
import MapKit

struct FlightDetailView: View {
    let flight: FlightState

    private var coordinateText: String {
        if let lat = flight.latitude, let lon = flight.longitude {
            return String(format: "%.4f, %.4f", lat, lon)
        }
        return "—"
    }

    private var speedText: String {
        if let v = flight.velocity { return String(format: "%.0f km/h", v * 3.6) }
        return "—"
    }

    var body: some View {
        List {
            // Aircraft Image Section
            if let imageURL = flight.aircraftImageURL {
                Section {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            Section("Flight") {
                LabeledContent("Callsign", value: flight.callsign?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? flight.callsign! : "Unknown")
                LabeledContent("Origin country", value: flight.originCountry ?? "Unknown")
                if let icao = flight.icao24 { LabeledContent("ICAO24", value: icao.uppercased()) }
                if let aircraftType = flight.aircraftType { LabeledContent("Aircraft", value: aircraftType) }
            }
            Section("Live data") {
                LabeledContent("Coordinates", value: coordinateText)
                LabeledContent("Speed", value: speedText)
                if let alt = flight.baroAltitude { LabeledContent("Baro altitude", value: String(format: "%.0f m", alt)) }
                if let hdg = flight.heading { LabeledContent("Heading", value: String(format: "%.0f°", hdg)) }
                if let vr = flight.verticalRate { LabeledContent("Vertical rate", value: String(format: "%.1f m/s", vr)) }
                if let onG = flight.onGround { LabeledContent("On ground", value: onG ? "yes" : "no") }
            }
            if let lat = flight.latitude, let lon = flight.longitude {
                Section("Map") {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                    )))
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationTitle(flight.callsign?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? flight.callsign! : "Flight details")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollContentBackground(.hidden)
        .background(Theme.Gradient.background)
    }
}
