import SwiftUI
import MapKit

struct AirportDetailView: View {
    let airport: Airport

    private var coordinate: CLLocationCoordinate2D? {
        guard let lat = airport.latitude, let lon = airport.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var body: some View {
        List {
            Section("Airport") {
                LabeledContent("Name", value: airport.name)
                LabeledContent("Location", value: "\(airport.city), \(airport.country)")
                if let iata = airport.iata { LabeledContent("IATA", value: iata) }
                if let icao = airport.icao { LabeledContent("ICAO", value: icao) }
                if let type = airport.type { LabeledContent("Type", value: type.replacingOccurrences(of: "_", with: " ")) }
                if let elev = airport.elevationFt { LabeledContent("Elevation", value: "\(elev) ft") }
                if let region = airport.region { LabeledContent("Region", value: region) }
                if let continent = airport.continent { LabeledContent("Continent", value: continent) }
                if let local = airport.localCode, !local.isEmpty { LabeledContent("Local code", value: local) }
                if let sched = airport.scheduledService, !sched.isEmpty { LabeledContent("Scheduled service", value: sched) }
                if let wiki = airport.wikipediaLink { LabeledContent("Wikipedia", value: wiki.absoluteString) }
                if let home = airport.homeLink { LabeledContent("Website", value: home.absoluteString) }
                if let kw = airport.keywords, !kw.isEmpty { LabeledContent("Keywords", value: kw) }
            }
            if let coord = coordinate {
                Section("Map") {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                    )))
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationTitle(airport.iata ?? airport.icao ?? "Airport")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollContentBackground(.hidden)
        .background(Theme.Gradient.background)
    }
}


