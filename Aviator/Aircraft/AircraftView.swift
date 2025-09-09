import SwiftUI
import ComposableArchitecture

struct AircraftView: View {
    let store: StoreOf<AircraftFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            NavigationStack {
                List {
                    Section("Popular models") {
                        Label("Airbus A320", systemImage: "airplane.circle")
                            .font(.title3)
                        Label("Boeing 737", systemImage: "airplane.circle")
                            .font(.title3)
                        Label("Embraer E190", systemImage: "airplane.circle")
                            .font(.title3)
                    }
                }
                .navigationTitle("Aircraft")
            }
        }
    }
}


