import SwiftUI

struct AirportsView: View {
    @State private var query: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Пошук") {
                    TextField("Назва або код IATA", text: $query)
                        .textInputAutocapitalization(.characters)
                }
                Section("Рекомендовані") {
                    Label("KBP — Boryspil", systemImage: "airplane.departure")
                    Label("LHR — London Heathrow", systemImage: "airplane.departure")
                    Label("JFK — New York JFK", systemImage: "airplane.departure")
                }
            }
            .navigationTitle("Аеропорти")
        }
    }
}

#Preview {
    AirportsView()
}


