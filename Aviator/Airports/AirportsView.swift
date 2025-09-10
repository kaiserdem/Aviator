import SwiftUI
import ComposableArchitecture

struct AirportsView: View {
    let store: StoreOf<AirportsFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    if viewStore.isLoading && viewStore.airports.isEmpty {
                        ProgressView("Loading…")
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)

                    } else if viewStore.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        List {
                            Section("Search") {
                                TextField("Name or IATA/ICAO", text: viewStore.binding(get: \.query, send: { .setQuery($0) }))
                                    .textInputAutocapitalization(.characters)
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .background(Theme.Palette.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Section("Featured") {
                                ForEach(defaultResults(viewStore.airports)) { a in
                                    NavigationLink(value: a) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(a.name).font(.title3)
                                                Text("\(a.city), \(a.country)").font(.caption).foregroundStyle(Theme.Palette.primaryRed)
                                            }
                                            Spacer()
                                            Text(a.iata ?? a.icao ?? "—").font(.headline)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    } else {
                        List {
                            Section("Search") {
                                TextField("Name or IATA/ICAO", text: viewStore.binding(get: \.query, send: { .setQuery($0) }))
                                    .textInputAutocapitalization(.characters)
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .background(Theme.Palette.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Section("Results") {
                                ForEach(filtered(viewStore.airports, query: viewStore.query)) { a in
                                    NavigationLink(value: a) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(a.name).font(.title3)
                                                Text("\(a.city), \(a.country)").font(.caption).foregroundStyle(Theme.Palette.primaryRed)
                                            }
                                            Spacer()
                                            Text(a.iata ?? a.icao ?? "—").font(.headline)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("Airports")
                .navigationDestination(for: Airport.self) { a in
                    AirportDetailView(airport: a)
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
                .task { await viewStore.send(.onAppear).finish() }
            }
        }
    }

    private func filtered(_ items: [Airport], query: String) -> [Airport] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return Array(items.prefix(100)) }
        return items.filter { a in
            a.name.localizedCaseInsensitiveContains(q) ||
            (a.city.localizedCaseInsensitiveContains(q)) ||
            (a.iata?.localizedCaseInsensitiveContains(q) ?? false) ||
            (a.icao?.localizedCaseInsensitiveContains(q) ?? false)
        }.prefix(100).map { $0 }
    }

    private func defaultResults(_ items: [Airport]) -> [Airport] {
        let filtered = items.filter { ($0.iata?.isEmpty == false) || ($0.icao?.isEmpty == false) }
        return Array(filtered.prefix(100))
    }
}


