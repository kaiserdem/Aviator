import SwiftUI
import ComposableArchitecture

struct AircraftView: View {
    let store: StoreOf<AircraftFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    if viewStore.isLoading && viewStore.titles.isEmpty {
                        ProgressView("Loading…")
                    } else {
                        List {
                            Section("Search") {
                                TextField("Model name", text: viewStore.binding(get: \.query, send: { .setQuery($0) }))
                                    .textInputAutocapitalization(.characters)
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .background(Theme.Palette.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Section("Models") {
                                ForEach(filtered(viewStore.titles, q: viewStore.query), id: \.self) { title in
                                    Button {
                                        viewStore.send(.selectTitle(title))
                                    } label: {
                                        Label(title, systemImage: "airplane.circle")
                                            .font(.title3)
                                    }
                                    .padding(5)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .navigationTitle("Aircraft")
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollContentBackground(.hidden)
                .background(Theme.Gradient.background)
                .task { await viewStore.send(.onAppear).finish() }
                .navigationDestination(item: Binding(
                    get: { viewStore.selected },
                    set: { _ in }
                )) { detail in
                    AircraftDetailView(detail: detail)
                }
            }
        }
    }

    private func filtered(_ titles: [String], q: String) -> [String] {
        let q = q.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return titles }
        return titles.filter { $0.localizedCaseInsensitiveContains(q) }
    }
}


