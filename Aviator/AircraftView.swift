import SwiftUI

struct AircraftView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Популярні моделі") {
                    Label("Airbus A320", systemImage: "airplane.circle")
                    Label("Boeing 737", systemImage: "airplane.circle")
                    Label("Embraer E190", systemImage: "airplane.circle")
                }
            }
            .navigationTitle("Літаки")
        }
    }
}

#Preview {
    AircraftView()
}


