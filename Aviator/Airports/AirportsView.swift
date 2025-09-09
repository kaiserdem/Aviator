import SwiftUI
import ComposableArchitecture

struct AirportsView: View {
    let store: StoreOf<AirportsFeature>
    @State private var query: String = ""

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            NavigationStack {
                List {
                    Section("Search") {
                        TextField("Name or IATA code", text: $query)
                            .textInputAutocapitalization(.characters)
                    }
                    Section("Featured") {
                        Label("KBP — Boryspil", systemImage: "airplane.departure")
                        Label("LHR — London Heathrow", systemImage: "airplane.departure")
                        Label("JFK — New York JFK", systemImage: "airplane.departure")
                    }
                }
                .navigationTitle("Airports")
            }
        }
    }
}


