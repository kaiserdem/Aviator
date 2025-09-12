
import SwiftUI
import ComposableArchitecture

@main
struct Aviator_v2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}

